import os
import hashlib
import random
from scipy.stats import norm
import math
import cma
import numpy as np
import time
from PUF.XORAPUF import XORArbiterPUF  # Adjust this import according to your project structure
from typing import Union, Callable
from numpy.random import default_rng
from hashlib import sha256

import galois
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding
from reedsolo import RSCodec, ReedSolomonError

def aes_key_from_seed(seed):
    if isinstance(seed, np.ndarray):
        seed = int(''.join(map(str, seed)), 2)
    else:
        seed = int(seed)
    binary_seed = bin(seed)[2:].zfill(256)
    seed_bytes = bytearray(int(binary_seed[i:i+8], 2) for i in range(0, len(binary_seed), 8))
    if len(seed_bytes) < 32:
        seed_bytes += b'\0' * (32 - len(seed_bytes))
    return bytes(seed_bytes)

def aes_encrypt(plaintext_list, key):
    """Encrypt a list of binary strings individually, appending IV to the ciphertext."""
    iv = os.urandom(16)  # Generate a random 16-byte IV
    #print("iv: ", iv)
    cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
    encrypted_list = []
    
    for plaintext in plaintext_list:
        # Convert binary string to bytes
        plaintext_bytes = int(plaintext, 2).to_bytes((len(plaintext) + 7) // 8, byteorder='big')
        encryptor = cipher.encryptor()
        encrypted_bytes = encryptor.update(plaintext_bytes) + encryptor.finalize()
        # Combine IV and encrypted data, then convert to binary string for storage
        encrypted_binary = ''.join(format(byte, '08b') for byte in (iv + encrypted_bytes))
        encrypted_list.append(encrypted_binary)
    
    return encrypted_list

def aes_decrypt(ciphertext_list, key):
    """Decrypt a list of binary strings individually, extracting IV from each."""
    decrypted_list = []
    for encrypted in ciphertext_list:
        # Extract IV and ciphertext from the binary string
        iv = bytes(int(encrypted[:128], 2).to_bytes(16, byteorder='big'))  # First 128 bits are the IV
        #print("iv in decr: ", iv)
        ciphertext = bytes(int(encrypted[i:i+8], 2) for i in range(128, len(encrypted), 8))
        cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
        decryptor = cipher.decryptor()
        decrypted_bytes = decryptor.update(ciphertext) + decryptor.finalize()
        # Convert decrypted bytes back to binary string
        decrypted_binary = ''.join(format(byte, '08b') for byte in decrypted_bytes)
        decrypted_list.append(decrypted_binary)
    return decrypted_list


####-----------tuning soundness parameter h:-------------------------------------#

####-----------key:-------------------------------------#
def derive_key(k_vec, max_k=None, width_bytes=None):
    """
    Streaming KDF: key = SHA256( k_1 || ... || k_N )

    - Fixed-width encoding for each k_i to avoid ambiguity.
    - width_bytes: if None, auto-chosen from max_k (or from observed max in k_vec).
    """
    h = sha256()
    # h.update(domain_tag)

    # # include parameters to prevent cross-protocol/key-reuse collisions
    # if params:
    #     # simple canonicalization: key=value\n pairs in sorted key order
    #     for k in sorted(params):
    #         v = str(params[k]).encode()
    #         h.update(k.encode()); h.update(b"="); h.update(v); h.update(b"\n")

    # N = len(k_vec)
    # commit to N (4-byte big-endian)
    # h.update(N.to_bytes(4, 'big'))

    # decide width
    if width_bytes is None:
        if max_k is None:
            max_k = max(k_vec) if k_vec else 0
        width_bytes = max(1, math.ceil((max_k.bit_length()) / 8))
        # round up to 1/2/4 bytes for alignment friendliness
        if width_bytes <= 1: width_bytes = 1
        elif width_bytes <= 2: width_bytes = 2
        elif width_bytes <= 4: width_bytes = 4
        elif width_bytes <= 8: width_bytes = 8
        else:
            # very large integers: use minimal necessary bytes
            pass

    # also encode the chosen width so decoders know how to parse (1 byte is enough up to 255)
    # h.update(bytes([width_bytes]))

    # stream each k_i in fixed width
    for ki in k_vec:
        if ki < 0:
            raise ValueError("k_i must be non-negative")
        h.update(int(ki).to_bytes(width_bytes, 'big'))

    return h.digest()  # 32-byte key (SHA-256)
###--------------A HASH function :
def hash1(bitstring: str, out_bits: int) -> np.ndarray:
    """
    Hash 'bitstring' to exactly 'out_bits' bits using SHA-256 in CTR mode.
    Returns a numpy int array of 0/1 of length out_bits.
    """
    need = out_bits
    acc_bits = []
    ctr = 0
    while len(acc_bits) < need:
        h = sha256((bitstring + f"|ctr={ctr}").encode()).digest()
        # expand 32 bytes -> 256 bits
        for byte in h:
            for b in range(7, -1, -1):
                acc_bits.append((byte >> b) & 1)
        ctr += 1
    return np.array(acc_bits[:out_bits], dtype=int)
# def hash1(bitstring, lambda_):
#     digest = hashlib.sha256(bitstring.encode()).digest()
#     bits = np.unpackbits(np.frombuffer(digest, dtype=np.uint8))
#     return bits[:lambda_]

####-----------RS: ------------------------------------------------------------------#    
def rs_encode_systematic(k_vec, m: int, q_bits: int):
    """
    RS(n = N + 2m + 1, k = N) over GF(2^q_bits) using the `galois` library.
    Returns:
      codeword_syms : np.ndarray of ints, length n, symbols in [0, 2^q_bits)
      parity_syms   : np.ndarray of ints, length 2m+1
    """
    N = len(k_vec)
    t = 2*m + 1
    n = N + t

    GF = galois.GF(2**q_bits)
    n0 = GF.order - 1  # = 2^q_bits - 1

    if n > n0:
        raise ValueError(
            f"Requested RS length n={n} exceeds max n0={n0} for q_bits={q_bits}. "
            "Increase q_bits (e.g., q_bits=10 gives n0=1023)."
         )
    
    # Ensure symbols fit the field
    max_sym = (1 << q_bits) - 1
    if any((ki < 0) or (ki > max_sym) for ki in k_vec):
        raise ValueError(
            f"All k_i must be in [0, {max_sym}] for q_bits={q_bits}. "
            f"Got max(k)={max(k_vec)}. Use B <= {max_sym} or increase q_bits."
        )
    
    s = n0 - n               # symbols to shorten
    k0 = N + s               # message length for the full-length code
    RS0 = galois.ReedSolomon(n0, k0, field=GF)  # systematic
    msg0 = GF.Zeros(k0)
    msg0[s:] = GF(k_vec)

    cw0 = RS0.encode(msg0)         # length n0 = 2^q_bits - 1
    cw_short = cw0[s:]             # puncture (remove) the first s symbols -> length n

    codeword_syms = np.array(cw_short, dtype=int)
    parity_syms   = codeword_syms[N:]  # last t symbols

    return codeword_syms, parity_syms
####-----------PUF: ------------------------------------------------------------------#
# Function to generate n-bit responses from an n-bit challenge
### New XOR_APUF to avoid puf re-instantiation:
def XOR_PUF(chal, puf_parameter, xor_arbiter_puf=None):
    """
    Generates an n-bit response from an n-bit challenge using XOR Arbiter PUF.

    Parameters:
        chal (np.ndarray or str): n-bit challenge (can be string or numpy array).
        puf_parameter (dict): Contains PUF configuration including n, k, weights, noise, etc.
        xor_arbiter_puf (XORArbiterPUF, optional): Reuse an existing instance to avoid re-instantiation.

    Returns:
        np.ndarray: n-bit response
    """
    n = len(chal)
    m = puf_parameter['n']

    if isinstance(chal, str):
        seed_challenge = np.array(list(chal), dtype=int)
    elif isinstance(chal, np.ndarray):
        seed_challenge = chal
    else:
        raise ValueError("Challenge must be a string or NumPy array.")

    # Split into m-bit chunks
    num_chunks = n // m
    chunks = np.zeros((num_chunks, m), dtype=int)
    for i in range(num_chunks):
        chunks[i, :] = seed_challenge[i * m:(i + 1) * m]

    # Instantiate the PUF only if not supplied
    if xor_arbiter_puf is None:
        xor_arbiter_puf = XORArbiterPUF(
            puf_parameter['n'],
            puf_parameter['k'],
            puf_parameter['weight_array'],
            puf_parameter['transform'],
            puf_parameter['combiner'],
            puf_parameter['sigma_noise'],
            puf_parameter['seed'],
            puf_parameter['vote_count'],
            puf_parameter['bias']
        )

    responses = np.zeros(n, dtype=int)

    for i in range(1, m):  # Skip index 0 to match your original pattern
        np.random.seed(puf_parameter['seed'] + i)
        seed_v = np.random.randint(0, 2, (1, m), dtype=int)
        for j in range(num_chunks):
            c = np.bitwise_xor(chunks[j, :], seed_v)
            responses[j * m + i] = xor_arbiter_puf.eval(c.reshape(1, -1)).flatten()[0]

    return responses


####-------
def generate_random_seed(lambda_):
    return random.getrandbits(lambda_)

def generate_random_value(lambda_):
    random_int = random.getrandbits(lambda_)
    binary_str = bin(random_int)[2:].zfill(lambda_)

    return np.array(list(binary_str), dtype=int)

def integer_to_binary_array(value, lambda_):
    binary_str = bin(value)[2:].zfill(lambda_)
    return np.array(list(binary_str), dtype=int)

def binary_array_to_int(binary_array):
    # Convert the binary array to a string of binary digits
    binary_str = ''.join(map(str, binary_array))
    # Convert the binary string to an integer
    integer_value = int(binary_str, 2)
    return integer_value


##lfsr:
## note : to avoid error about the large int, it's better to have seed in int type not binary type.


def encrypt(solution, seed):
    # Convert seed to an integer if it's a binary string
    if isinstance(seed, str):
        seed = int(seed, 2)  
    encrypted_solution = []  
    for binary_string in solution:
        # Initialize an encrypted string
        encrypted_string = ''       
        # Process each character in the binary string
        for char in binary_string:
            # Since the characters are '0' or '1', convert them to integers, apply the seed and take mod 2
            encrypted_char = (int(char) + seed) % 2
            encrypted_string += str(encrypted_char)       
        # Append the processed binary string to the result
        encrypted_solution.append(encrypted_string)   
    return encrypted_solution

####-----------Comapring the results:----------------------------------------------------------------#
def solution_equality(s1, s2):
    
    if len(s1) != len(s2):
        return False
    for v1, v2 in zip(s1, s2):
        if v1 != v2:
            return False
    return True
####------------------------------------------------------------------------------------------------------#

def bin_to_bits(val, length):
    return np.array(list(bin(val)[2:].zfill(length)), dtype=int)

def tweak_hash(ti, c_prime_i, lambda_):
    tweaked = ti + bin(c_prime_i)[2:].zfill(lambda_)
    hashed = sha256(tweaked.encode()).hexdigest()
    hashed_bits = bin(int(hashed, 16))[2:].zfill(256)[:lambda_]
    return np.array(list(hashed_bits), dtype=int)



def Hamming_Distance(bitstring1, bitstring2):
    # Ensure both inputs are in binary string format if they are integers
    if isinstance(bitstring1, np.integer):
        bitstring1 = np.binary_repr(bitstring1, width=lambda_)  # Assuming 'lambda_' is the bit width
    if isinstance(bitstring2, np.integer):
        bitstring2 = np.binary_repr(bitstring2, width=lambda_)
    # Convert strings to lists for iteration if they aren't already lists
    if isinstance(bitstring1, str):
        bitstring1 = list(bitstring1)
    if isinstance(bitstring2, str):
        bitstring2 = list(bitstring2)
    # Calculate the Hamming distance between two bitstrings
    return sum(b1 != b2 for b1, b2 in zip(bitstring1, bitstring2))

def decrypt(encrypted_solution, seed):
    # Convert seed to an integer if it's a binary string
    if isinstance(seed, str):
        seed = int(seed, 2)
    
    decrypted_solution = []

    for binary_array in encrypted_solution:
        if isinstance(binary_array, np.ndarray):
            binary_array = binary_array.flatten()  # Ensure it's a 1D array
        else:
            binary_array = np.array(list(binary_array), dtype=int)  # Convert to int if it's a string

        # Initialize a decrypted string
        decrypted_string = ''.join(str((int(bit) - seed) % 2) for bit in binary_array)
        decrypted_solution.append(decrypted_string)

    return decrypted_solution
# === New: distribution D with bound B ===
# def sample_k_from_D(B: int, mode="geometric", p=0.15) -> int:
#     """
#     Sample k ~ D with maximum bound B (returns 0..B-1).
#     - 'geometric' uses Geo(p), then caps modulo B to stay in range.
#     """
#     if B <= 0:
#         raise ValueError("B must be >= 1")
#     if mode == "geometric":
#         # numpy geometric returns values in {1,2,...} with P(X=k)= (1-p)^(k-1) p
#         draw = np.random.geometric(p)
#         return draw % B
#     elif mode == "uniform":
#         return np.random.randint(0, B)
#     else:
#         raise ValueError(f"Unsupported D: {mode}")
def sample_k_from_D(B: int, mode="geometric", p=0.15) -> int:
    if B <= 0:
        raise ValueError("B must be >= 1")
    if mode == "geometric":
        # use a local NumPy Generator so we don't touch the global RNG
        rng = np.random.default_rng()
        draw = rng.geometric(p)                 # {1,2,...}
        return draw % B
    elif mode == "uniform":
        return random.randrange(B)              # 0..B-1, independent of NumPy's RNG
    else:
        raise ValueError(f"Unsupported D: {mode}")
###==========PUZ:========================###

def puz (k, x: int, lambda_: int, puf_parameter: dict) -> tuple[int, np.ndarray]:
    """
    Implements your pseudo-code:
      c <- Hash(k || x)
      r <- PUF(c)  (len lambda_)
    Returns (k_i (int), r_i (np.ndarray of shape (lambda_,)))
    """
    k_bits = format(k, f'0{lambda_ // 4}b')
    x_bits = format(x, f'0{lambda_ // 4}b')
    bitstring = k_bits + x_bits  # legnth of bitstring= lambda_//2 
    c = hash1(bitstring, lambda_)       
    r = XOR_PUF(c, puf_parameter)
    return r
def puz_round(x: int, B: int, lambda_: int, puf_parameter: dict, D_mode="geometric", D_p=0.15) -> tuple[int, np.ndarray]:
    """
    Implements your pseudo-code:
      k <- sample from D bounded by B
      c <- Hash(k || x)
      r <- PUF(c)  (len lambda_)
    Returns (k_i (int), r_i (np.ndarray of shape (lambda_,)))
    """
    k = sample_k_from_D(B, mode=D_mode, p=D_p)
    r= puz (k, x, lambda_, puf_parameter)
    return int(k), r

def puz_gen(N: int, B: int, lambda_: int, puf_parameter: dict, D_mode="geometric", D_p=0.15):
    r = []
    k=[]
    for i in range(1, N + 1):               
        ki , ri =puz_round(i, B, lambda_, puf_parameter, D_mode=D_mode, D_p=D_p)
        print(f"i={i}, ki={ki}")
        r.append(np.array(ri, dtype=int))
        k.append(int(ki))
    return  k, r # list[int], list[np.ndarray]

# === New: TLP.Gen with RS ===
def tlp_gen_rs(N: int, B: int, lambda_: int, q_bits: int, m: int,
               S_binary_list: list[str], puf_parameter: dict,
               D_mode="geometric", D_p=0.15):
    """
    Implements your Algorithm TLP.Gen (generation only).

    Inputs:
      - N: number of rounds
      - B: max bound for k sampling
      - lambda_: bit-length of PUF challenge/response
      - q_bits: GF size (use 8 => GF(256))
      - m: RS setting -> parity symbols = 2m+1
      - S_binary_list: the plaintext payload as a list of binary strings (your code uses list)
      - puf_parameter: your XOR_PUF config

    Returns:
      Z: list[str]  (ciphertexts for each si, using AES you already have)
      H: dict       (helper data) with:
         - 'r_vec': list[np.ndarray] of length N, each of lambda_ bits
         - 'parity': bytes of length (2m+1)
         - 'N','B','lambda','q_bits','m'
    """
    # Step 1–2: generate per-round (k_i, r_i)
    k_vec, r_vec = puz_gen(N, B, lambda_, puf_parameter, D_mode=D_mode, D_p=D_p)

    # Step 3: RS encode the data part (k_vec) to obtain parity symbols
    _, parity = rs_encode_systematic(k_vec, m=m, q_bits=q_bits)
    # print("RS parity:", parity)

    # Step 4: Store helper data H
    H = {
        "r_vec": r_vec,               # list of PUF responses (public helper data)
        "parity": parity,       # RS parity symbols (public helper data)
        "N": N, "B": B, "lambda": lambda_, "q_bits": q_bits, "m": m
    }

    # Step 5: derive key and encrypt the solution payload S
    key = derive_key(k_vec)  # AES-256
    print("Derived AES key:", key.hex())
    Z = aes_encrypt(S_binary_list, key)  # you already have aes_encrypt in your file

    return Z, H  # k_vec returned only for testing; do NOT publish in real use
###==========Solving:========================###
def _ensure_parity_symbols(parity, q_bits: int, t: int):
    """
    Accept parity either as a numpy/int list of symbols or as packed bytes (optional extension).
    Here we expect parity to already be a list/array of ints (your current H['parity']).
    """
    if isinstance(parity, (list, np.ndarray)):
        arr = np.array(parity, dtype=int)
        if len(arr) != t:
            raise ValueError(f"Parity length mismatch: expected {t}, got {len(arr)}")
        return arr
    raise TypeError("Helper parity should be a list/ndarray of RS symbols (ints).")

# def rs_recover_kvec_shortened(k_hat, parity_syms, m: int, q_bits: int):
    """
    Shortened RS decode that matches your encoder:
      - Full-length RS(n0, k0) with n0 = 2^q_bits - 1
      - Shortening by s = n0 - (N + 2m + 1): encode [0]^s || k, then puncture the first s symbols
    For decode:
      - Reconstruct cw0_hat = [0]^s || (k_hat || parity) and call RS0.decode(cw0_hat)
      - Extract recovered k from the decoded message (skip the leading s).
    """
    N = len(k_hat)
    t = 2*m + 1
    n = N + t

    GF = galois.GF(2**q_bits)
    n0 = GF.order - 1
    if n > n0:
        raise ValueError(f"n={n} exceeds 2^{q_bits}-1={n0}. Increase q_bits.")

    s  = n0 - n           # shortened amount
    k0 = N + s            # message length for full-length RS

    RS0 = galois.ReedSolomon(n0, k0, field=GF)  # systematic

    # Build guessed shortened codeword: k_hat || parity (length n)
    cw_short_hat = GF(np.concatenate([np.array(k_hat, dtype=int),
                                      np.array(parity_syms, dtype=int)]))
    # Undo puncturing: prepend s zeros to get full length n0
    cw0_hat = GF.Zeros(n0)
    cw0_hat[s:] = cw_short_hat

    # Decode -> returns message of length k0 (GF array): [0]^s || k_true
    msg0 = RS0.decode(cw0_hat)
    k_rec = np.array(msg0[s:], dtype=int)  # strip the leading s zeros
    return k_rec
##fixed RS regarding erasures:
def rs_recover_kvec_shortened(k_hat, parity_syms, m: int, q_bits: int, erasures_k=None):
    """
    Shortened RS decode that matches rs_encode_systematic(), WITH erasure handling.

    Parameters
    ----------
    k_hat : array-like length N
        Estimated data symbols. Missed rounds can be any placeholder (e.g., 0).
    parity_syms : array-like length (2m+1)
        Parity symbols from helper data.
    m : int
        RS parameter, parity count is t=2m+1.
    q_bits : int
        Field size, GF(2^q_bits).
    erasures_k : list[int] or None
        0-based indices in the data part (0..N-1) that are erasures (missed rounds).

    Returns
    -------
    k_rec : np.ndarray length N
    """
    import numpy as np
    import galois

    N = len(k_hat)
    t = 2 * m + 1
    n = N + t

    GF = galois.GF(2**q_bits)
    n0 = GF.order - 1
    if n > n0:
        raise ValueError(f"n={n} exceeds 2^{q_bits}-1={n0}. Increase q_bits.")

    # Shortening parameters (must match encoder)
    s = n0 - n
    k0 = N + s

    RS0 = galois.ReedSolomon(n0, k0, field=GF)

    k_hat_arr = np.array(k_hat, dtype=int).reshape(-1)
    parity_arr = np.array(parity_syms, dtype=int).reshape(-1)
    if len(parity_arr) != t:
        raise ValueError(f"Parity length mismatch: expected {t}, got {len(parity_arr)}")

    # Build shortened codeword guess (length n), then unshorten to length n0
    cw_short_hat = GF(np.concatenate([k_hat_arr, parity_arr]))
    cw0_hat = GF.Zeros(n0)
    cw0_hat[s:] = cw_short_hat

    # Build boolean erasure mask of length n0
    erasures_mask = np.zeros(n0, dtype=bool)

    # Build full-length erasure positions (shift by s due to shortening)
    erase_pos0 = None
    if erasures_k is not None:
        erasures_k = [int(x) for x in erasures_k]
        for pos in erasures_k:
            if pos < 0 or pos >= N:
                raise ValueError(f"erasures_k out of range: {pos} (valid 0..{N-1})")
        # erase_pos0 = [s + pos for pos in erasures_k]
            erasures_mask[s + pos] = True  # shift due to shortening

    # Decode (galois API differs across versions, try common parameter names)
    # if erase_pos0 is None:
    #     msg0 = RS0.decode(cw0_hat)
    # else:
    #     try:
    #         msg0 = RS0.decode(cw0_hat, erase_pos=erase_pos0)
    #     except TypeError:
    #         try:
    #             msg0 = RS0.decode(cw0_hat, erasures=erase_pos0)
    #         except TypeError:
    #             msg0 = RS0.decode(cw0_hat, erasure_pos=erase_pos0)
    # print(f"[RS] FN={int(erasures_mask.sum())}, parity={2*m+1}")

    # Decode
    msg0 = RS0.decode(cw0_hat, erasures=erasures_mask)
    # msg0 = [0]^s || k_true
    k_rec = np.array(msg0[s:], dtype=int)
    return k_rec

# --- main solver ---

def tlp_solve_rs(Z, H, tau: float, puf_parameter: dict):
    """
    Solve (Z, H) generated by tlp_gen_rs.

    Inputs:
      - Z: list[str]  ciphertext(s) (binary strings as produced by aes_encrypt)
      - H: dict with keys:
           'r_vec'   : list[np.ndarray] of length N (each lambda_ bits, 0/1 ints)
           'parity'  : np.ndarray/list of length (2m+1) with RS symbols (ints)
           'N','B','lambda','q_bits','m'
      - tau: threshold in [0,1], we accept r' if HD(r',r) <= tau*lambda
      - puf_parameter: your XOR_PUF configuration

    Returns:
      - S: list[str] decrypted plaintext(s) (binary strings)
      - info: dict with stats about search and RS correction
    """
    r_vec    = H["r_vec"]
    parity   = H["parity"]
    N        = int(H["N"])
    B        = int(H["B"])
    lambda_  = int(H["lambda"])
    q_bits   = int(H["q_bits"])
    m        = int(H["m"])

    t = 2*m + 1
    parity_syms = _ensure_parity_symbols(parity, q_bits, t)

    # 1) Brute-force each round i to find a candidate k_i inside the Hamming ball
    threshold = int(math.floor(tau * lambda_))
    k_hat = []
    misses = []

    for i in range(1, N + 1):
        r_i = np.array(r_vec[i-1], dtype=int)
        found = False
        print(f"Solving round i={i}")

        # Search k in [0, B-1] (you can randomize the order if needed)
        for k in range(B):
            r_i_prime = puz(k,i , lambda_, puf_parameter)  # np array 0/1
            if Hamming_Distance(r_i_prime, r_i) <= threshold:
                k_hat.append(int(k))
                print(f"  Found k[{i}] = {k}")
                found = True
                break

        if not found:
            # mark an erasure; simple approach: insert 0 and let RS fix it
            k_hat.append(0)
            misses.append(i)

    # 2) RS decode (shortened) to reconstruct the true k-vector
    try:
        k_rec = rs_recover_kvec_shortened(k_hat, parity_syms, m=m, q_bits=q_bits)
        rs_ok = True
    except Exception as e:
        # Too many errors/erasures
        rs_ok = False
        raise

    # 3) Derive key and decrypt
    key = derive_key(list(map(int, k_rec)))    # 32 bytes (AES-256)
    S   = aes_decrypt(Z, key)                  # list[str] of binary strings

    info = {
        "miss_count": len(misses),
        "miss_positions": misses,
        "rs_success": rs_ok
    }
    return S, info
###=========================================###

# def sol_puz_tweak_noisy(c0_bits, tweaks, N, B, Z, helper_data, puf_parameter, T_threshold):
#     lambda_ = len(c0_bits)
#     ci = c0_bits.copy()
#     Ti_len = int(np.ceil(np.log2(N + 1)))
#     Ci_len = lambda_ - Ti_len
#     ri_1 = XOR_PUF(ci, puf_parameter)
#     for i in range(1, N + 1):
#         Ti = format(i , f'0{Ti_len}b')
#         #Ti = tweaks[i - 1]
#         # ri_1 = XOR_PUF(ci, puf_parameter)
#         found = False
#         for ki in range(B):
#             #ri_1 = XOR_PUF(ci, puf_parameter)
#             r_int = int(''.join(map(str, ri_1)), 2)
#             c_prime_i = (r_int + ki) % (2 ** Ci_len)
#             c_prime_bin = format(c_prime_i, f'0{Ci_len}b')
#             ci_candidate_bin = Ti + c_prime_bin
#             ci_candidate = np.array(list(ci_candidate_bin), dtype=int)
#             #ci=ci_candidate # for the next iteration i 
#             ri = XOR_PUF(ci_candidate, puf_parameter)
#             hd = Hamming_Distance(ri, helper_data[i - 1])
#             print(f"i={i}, ki={ki}, hd={hd}")
#             if hd <= T_threshold * lambda_:
#                 ci = ci_candidate
#                 ri_1=ri
#                 found = True
#                 break

#         if not found:
#             print(f"Warning: no valid ki at i={i}")

#     #rN = XOR_PUF(ci, puf_parameter)
#     rN=ri
#     rN_int = int(''.join(map(str, rN)), 2)

#     S_recovered = []
#     for idx, zi in enumerate(Z):
#         challenge_int = (rN_int + idx) % (2 ** lambda_)
#         challenge_bits = np.array(list(bin(challenge_int)[2:].zfill(lambda_)), dtype=int)
#         zi_puf = XOR_PUF(challenge_bits, puf_parameter)
#         zi_array = np.array(list(zi), dtype=int)
#         si = np.bitwise_xor(zi_puf, zi_array)
#         S_recovered.append(''.join(map(str, si)))

#     return S_recovered
# def XOR_PUF2(chal: np.ndarray, puf_parameter: dict) -> np.ndarray:
#     np.random.seed(np.sum(chal) + puf_parameter['seed'])  # simplistic noise modeling
#     return np.random.randint(0, 2, len(chal), dtype=int)
# def XOR_PUF2(chal: np.ndarray, puf_parameter: dict) -> np.ndarray:
#     # Use SHA256-based seed from challenge bits
#     chal_str = ''.join(map(str, chal))
#     digest = sha256(chal_str.encode()).digest()
#     np.random.seed(int.from_bytes(digest[:4], 'big'))
#     return np.random.randint(0, 2, len(chal), dtype=int)



####------------------------------------------------------------------------------------------------------#
#### Parameters:
t=150
tc=0.022
# tc=1.4
evaluations=1
e=t*0.1
p=0.95
B_min=5
T_threshold=0.2
n = 128  # Number of bits in each vector
lambda_ = n  # Security parameter
##About Expansion function:
taps = [n, n-1, 1]  # Example taps for a primitive polynomial of degree n

puf_parameter = {  
    'n': 64,  # num_stages in the PUF
    'k': 4,  # num_xors
    'weight_array': np.random.randn(4, 64),
    'transform': lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2),
    'combiner': lambda x: np.prod(x, axis=1),
    'sigma_noise': 1,
    'seed': 42,
    'vote_count': 1,
    'bias': None
}
chal = np.random.randint(0, 2, (1, 64))
puf = XORArbiterPUF(
    n=64, k=4,
    weight_array=np.random.randn(4, 64),
    transform=lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2),
    combiner=lambda x: np.prod(x, axis=1),
    sigma_noise=1,  # high noise
    seed=42,
    vote_count=1
)

# Run multiple evaluations
responses = [puf.eval(chal)[0] for _ in range(1000)]
print("============================")
# print("Flips:", 1000 - sum(responses))  # Should show some flips
S_sol = []
# Example parameters
N = 2
B = 100            # max symbol value (must be < 2^q_bits)
lambda_ = 128     # PUF r length
m = 4             # => 2m+1 = 9 parity symbols
n = N + (2*m + 1)
min_q_bits=8
q_bits = max(min_q_bits, math.ceil(math.log2(n + 1)))
D_mode="uniform"
D_mode="geometric"
D_p=0.1
tau=0.2 ##threshold for the HD
# Build a tiny plaintext set S (like your code: list of n-bit strings)
n_bits_payload = 128
S = [''.join(str(b) for b in np.random.randint(0, 2, n_bits_payload)) for _ in range(3)]

# Use your existing puf_parameter dict
# Z, H= tlp_gen_rs(N, B, lambda_, q_bits, m, S, puf_parameter, D_mode, D_p)
# S_sol, info = tlp_solve_rs(Z, H, tau, puf_parameter=puf_parameter)
# print("Ciphertexts Z (len):", len(Z))
# print("Helper has", len(H["r_vec"]), "PUF responses and", len(H["parity"]), "RS parity symbols.")
# # print("S_Sol: ", S_sol)
# if solution_equality(S, S_sol):
#     print("The solved solution is the same as locked solution.")
# else:
#     print("The solved solution is not the same as locked solution!!")
# Initialize the solution set S



###------------


# Define a wrapper function for your specific PUF instance
def puf_instance(challenge, puf_parameters):
    return XOR_PUF(challenge, puf_parameters)

# Test the reliability
#reliability_results = test_reliability(puf_instance, puf_parameters)
#print("Average Reliability Score:", reliability_results["average_reliability"])

###-------------

# for k in range (evaluations):
#     time1 = time.time()
    
#     #c0, T, Z, helper_data= Puz_Gen_NoisyPUF_TW(N2, B2, S, lambda_, puf_parameter)
#     c0, T, Z, helper_data=gen_puz_tweak_noisy(N2, B2, lambda_, S, puf_parameter)   
#     time2 = time.time()
#     gen_duration+=(time2-time1)
#     print("Z:",Z)
#     time3 = time.time()
#     S_sol=sol_puz_tweak_noisy(c0, T, N2, B2, Z, helper_data, puf_parameter, T_threshold)
#     time4 = time.time()
#     print("Puz_Gen function duration:", time2-time1)
#     print("Puz_Sol_Noisy_PUF function duration:", time4-time3)
#     print("tc*(L+2+2*N2): ", tc*(L+2+2*N2))
# print("S  : ", S)
# print("S_Sol: ", S_sol)
# if solution_equality(S, S_sol):
#     print("The solved solution is the same as locked solution.")
# else:
#     print("The solved solution is not the same as locked solution!!")
