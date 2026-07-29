# tlp_gen.py (snippet)
from puf_bridge import PUFDevice
from GEN_SOL_RS import hash1, sample_k_from_D, rs_encode_systematic, derive_key, aes_encrypt
from hashlib import sha256
import secrets, json
import numpy as np, math
from tlp_solve import bits_to_bytes, bytes_to_bits   # reuse the helpers we wrote
####--------------------------------
# def puz_device(k, x: int, lambda_: int, eval_device) -> np.ndarray:
#     """
#     Implements:
#         c <- Hash(k || x)
#         r <- FPGA_PUF(c)
#     """
#     k_bits = format(k, f'0{lambda_ // 4}b')
#     x_bits = format(x, f'0{lambda_ // 4}b')
#     bitstring = k_bits + x_bits
#     c = hash1(bitstring, lambda_)
#     r = eval_device.eval(c)    # device instead of XOR_PUF
#     return r

# def puz_round_device(x: int, B: int, lambda_: int, eval_device, D_mode="geometric", D_p=0.15):
#     k = sample_k_from_D(B, mode=D_mode, p=D_p)
#     r = puz_device(k, x, lambda_, eval_device)
#     return int(k), r

# def puz_gen_device(N: int, B: int, lambda_: int, eval_device, D_mode="geometric", D_p=0.15):
#     r = []
#     k = []
#     for i in range(1, N+1):
#         ki, ri = puz_round_device(i, B, lambda_, eval_device, D_mode=D_mode, D_p=D_p)
#         print(f"i={i}, ki={ki}")
#         r.append(np.array(ri, dtype=int))
#         k.append(ki)
#     return k, r

# -------------------------------------------------
# One round of puzzle generation on FPGA
# -------------------------------------------------
def puz_device(k, x, lambda_, eval_device):
    """
    Generate one challenge/response pair on the FPGA PUF.
    Args:
        k (int): secret value
        x (int): round index
        lambda_ (int): challenge/response bitlength (must be 128 for UART bridge)
        eval_device (PUFDevice): wrapper for UART communication
    Returns:
        (int, np.ndarray): the chosen k and the λ-bit response vector
    """
    # k||x as binary strings
    k_bits = format(k, f'0{lambda_ // 4}b')
    x_bits = format(x, f'0{lambda_ // 4}b')
    bitstring = k_bits + x_bits

    # Hash → λ-bit challenge vector
    c_bits = hash1(bitstring, lambda_)
    # print("Challenge:", c_bits)

    # Send to FPGA: pack bits→bytes → UART → unpack back to bits
    c_bytes = bits_to_bytes(c_bits)
    # r_bytes = eval_device.eval(c_bytes)
    r_bits = eval_device.eval(c_bits)
    # r_bits  = bytes_to_bits(r_bytes, lambda_)

    return k, r_bits


# -------------------------------------------------
# Multi-round puzzle generation
# -------------------------------------------------
def puz_gen_device(N, B, lambda_, eval_device, D_mode="geometric", D_p=0.5):
    """
    Generate (k_vec, r_vec) across N rounds using real FPGA PUF.
    """
    k_vec = []
    r_vec = []

    for i in range(1, N + 1):
        # sample k_i from distribution D
        if D_mode == "geometric":
            # geometric sampling with success prob p
            k_i = np.random.geometric(p=D_p) - 1
            # if k_i >= B:  # clip to max B-1 
            #     k_i = B - 1#collapse tail mass to B-1
            while k_i >= B:##Regenate until in range
                k_i = np.random.geometric(p=D_p) - 1
        elif D_mode == "uniform":
            k_i = np.random.randint(0, B)
        else:
            raise ValueError(f"Unknown D_mode={D_mode}")

        # query FPGA
        k_val, r_val = puz_device(k_i, i, lambda_, eval_device)
        k_vec.append(k_val)
        r_vec.append(r_val)

    return k_vec, r_vec
####--------------------------------
def tlp_gen_rs_device(N: int, B: int, lambda_: int, q_bits: int, m: int,
                      S_binary_list: list[str], eval_device,
                      D_mode="geometric", D_p=0.15):
    k_vec, r_vec = puz_gen_device(N, B, lambda_, eval_device, D_mode=D_mode, D_p=D_p)
    # print(f"k_vec:", k_vec)
    vec_mean, vec_std = np.mean(k_vec), np.std(k_vec)
    print(f"k_vec mean = {vec_mean:.2f}, std = {vec_std:.2f}")
    _, parity = rs_encode_systematic(k_vec, m=m, q_bits=q_bits)
    H = {
        "r_vec": r_vec,
        "parity": parity,
        "N": N, "B": B, "lambda": lambda_, "q_bits": q_bits, "m": m
    }
    key = derive_key(k_vec)
    Z = aes_encrypt(S_binary_list, key)
    return Z, H, k_vec
####--------------------------------


# dev = PUFDevice("/dev/ttyUSB1")
# N = 1000
# B = 5000
# lambda_ = 64
# m = 10
# q_bits = max(8, math.ceil(math.log2(N + 2*m + 1)))
# S = [''.join(str(b) for b in np.random.randint(0, 2, 64)) for _ in range(3)]

# Z, H = tlp_gen_rs_device(N, B, lambda_, q_bits, m, S, dev, D_mode="geometric", D_p=0.1)
# print("Puzzle generated: Z, H ready")

