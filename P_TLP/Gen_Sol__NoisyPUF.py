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


from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding

# def aes_key_from_seed(seed):
#     if isinstance(seed, np.ndarray):
#         # Convert the array to an integer if it's not already
#         seed = int(''.join(map(str, seed)), 2)
#     else:
#         # Ensure the seed is an integer, necessary for subsequent operations
#         seed = int(seed)
#     # Assuming seed is an integer, convert it to a binary string first
#     binary_seed = bin(seed)[2:].zfill(256)  # Ensure it's at least 256 bits long
#     seed_bytes = bytearray(int(binary_seed[i:i+8], 2) for i in range(0, len(binary_seed), 8))

#     # Ensure the key is 32 bytes (256 bits)
#     if len(seed_bytes) < 32:
#         # Pad the seed_bytes to 32 bytes if necessary
#         seed_bytes += b'\0' * (32 - len(seed_bytes))
#     return bytes(seed_bytes)


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

# def aes_encrypt(plaintext_list, key):
#     """Encrypt a list of binary strings individually."""
#     iv = os.urandom(16)  # Generate a random 16-byte IV
#     print("iv: ", iv)
#     cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
#     print("cipher:", cipher)
#     encrypted_list = []
    
#     for plaintext in plaintext_list:
#         # Convert binary string to bytes
#         plaintext_bytes = int(plaintext, 2).to_bytes((len(plaintext) + 7) // 8, byteorder='big')
#         encryptor = cipher.encryptor()
#         encrypted_bytes = encryptor.update(plaintext_bytes) + encryptor.finalize()
#         # Convert encrypted bytes back to binary string
#         encrypted_binary = ''.join(format(byte, '08b') for byte in encrypted_bytes)
#         encrypted_list.append(encrypted_binary)
    
#     return encrypted_list



# def aes_decrypt(ciphertext_list, key):
#     decrypted_list = []
#     for encrypted in ciphertext_list:
#         iv = bytes.fromhex(encrypted[:32])  # Extract the hex IV
#         print("iv in decrypt:  ", iv)
#         encrypted_data = encrypted[32:]
#         ciphertext = bytes(int(encrypted_data[i:i+8], 2) for i in range(0, len(encrypted_data), 8))
#         cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
#         print("cipher: ", cipher)
#         decryptor = cipher.decryptor()
#         decrypted_bytes = decryptor.update(ciphertext) + decryptor.finalize()
#         decrypted_binary = ''.join(format(byte, '08b') for byte in decrypted_bytes)
#         decrypted_list.append(decrypted_binary)
#     return decrypted_list

#from PUF import XorArbiterPuf
####-----------tuning soundness parameter h:-------------------------------------#
def create_objective_function(t, tc, e):
    # Constant parameters: t, tc, e, p_min
    def objective_function(params):
        h = params
        # Example evaluation using constants and parameters
        # N = 4 * h**2 * t**2 / (3 * e**2)
        # B = 3 * e**2 / (2 * h**2 * t * tc)

        # N = h**2 * t**2 / (6 * e**2)
        # B = 3 * e**2 / (h**2 * t * tc)

        B=((9*(e**4))/((h**4)*(tc**3)*t))**(1/3)
        N=((h**2)*B*t*tc)/(3*(e**2))

        mu=(N*B)/2
        sig=(np.sqrt(N/12))*(B)*tc
        # Convert to scalar if necessary
        if isinstance(N, np.ndarray) and N.size == 1:
            N = N.item()  # Convert single-item array to scalar
        if isinstance(B, np.ndarray) and B.size == 1:
            B = B.item()
        
        N_r=round(N)
        B_r=round(B)
        mu_r=(N_r*B_r)/2
        sig_r=(np.sqrt(N_r/12))*(B_r)*tc
        # Hypothetical evaluation metric
        loss = abs(mu - (mu_r)) + abs(sig - (sig_r))
        return loss
    return objective_function

def opt(t, tc, e, p_min, B_min):

    # Optimization with CMA-ES
    h_min = -norm.ppf((1 - p_min) / 2)
    h=h_min  
    initial_params = [h]  
    h_max=np.sqrt((3* e**2)/(2*B_min *t*tc))
    print("h_max:",h_max)
    print("h_min:",h_min)
    objective_function = create_objective_function(t, tc, e)
    options = {'bounds': [h_min, h_max], 'seed': 1234}
    es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
    es.optimize(objective_function)
    # Access the best solution after the optimization
    h_tuned= es.result.xbest  # Best solution found
    best_value = es.result.fbest  # Objective value of the best solution

    p_real=1-2*(norm.cdf(-(h_tuned)))
    
    # N = 4 * (h_tuned)**2 * t**2 / (3 * e**2)
    # B = 3 * e**2 / (2 * (h_tuned)**2 * t * tc)

    # N = (h_tuned)**2 * t**2 / (6 * e**2)
    # B = 3 * e**2 / ((h_tuned)**2 * t * tc)

    B=((9*(e**4))/((h_tuned**4)*(tc**3)*t))**(1/3)
    N=((h_tuned**2)*B*t*tc)/(3*(e**2))


    sig_real=(np.sqrt(N/12))*(B)*tc
    mu=(N*B)/2

    ee=2*sig_real*h_tuned
    return h_tuned, N, B, p_real, sig_real, mu, best_value, ee

####-----------PUF: ------------------------------------------------------------------#
# Function to generate n-bit responses from an n-bit challenge
def XOR_PUF(chal, puf_parameter):

    n=len(chal)#128
    m=puf_parameter['n'] #64
    # Ensure the challenge is a numpy array (convert if it's not)
    if isinstance(chal, str):
        # Assuming chal is a binary string, convert it
        seed_challenge = np.array(list(chal), dtype=int)
    elif isinstance(chal, np.ndarray):
        seed_challenge = chal
    else:
        raise ValueError("Challenge format not supported.")

    seedd = puf_parameter['seed']
    #print("len(seed_challenge):",n)
    num_chunks = n // m  # Each chunk is 64 bits

    # Split the binary string into 64-bit chunks
    chunks= np.zeros((num_chunks, m), dtype=int)
    for i in range(num_chunks):
         chunks[i,:]=seed_challenge[i * m:(i + 1) * m]

    responses = np.zeros(n, dtype=int)
    
    # Create the PUF instance
    xor_arbiter_puf = XORArbiterPUF(
        m,  # The PUF has 64 stages
        puf_parameter['k'],
        puf_parameter['weight_array'],
        puf_parameter['transform'],
        puf_parameter['combiner'],
        puf_parameter['sigma_noise'],
        puf_parameter['seed'],
        puf_parameter['vote_count'],
        puf_parameter['bias']
    )
    
    # Evaluate each segment and collect the responses
    for i in range (1, m):
        np.random.seed(seedd+i)
        seed_v=np.random.randint(0, 2, (1,m), dtype=int)

        for j in range (num_chunks):

            c=np.bitwise_xor(chunks[j,:],seed_v)
            responses[j*m+i,]=xor_arbiter_puf.eval(c)
    
    return responses

     
####-----------Generate Puzzle: ------------------------------------------------------------------#
def Puz_Gen(N, B, S, lambda_, puf_parameter):
    taps = [128, 127, 1]
    s0 = generate_random_seed(lambda_)
    si=s0
    H = []
    
    for i in range(N):

        ss = E2(si, taps, lambda_, B) 
        si = [integer_to_binary_array(vector, lambda_) for vector in ss]
        j = random.randint(0, B-1)
        si_j = ss[j]
        t1=time.time()
        cc = E2(si_j, taps, lambda_, lambda_)
        t2=time.time()
        
        ci = [integer_to_binary_array(vector, lambda_) for vector in cc]
        si_plus1 = generate_random_value(lambda_)
        ri = []
        #print("s", i, " _G:  ", si_plus1)
        for k in range(lambda_):
            if si_plus1[k] == 0:
                ri_k = generate_random_value(lambda_)
            else:
                tt=time.time()
                ri_k = XOR_PUF(ci[k], puf_parameter)
                ttt=time.time()
            ri.append(ri_k)
            H.append(ri_k)

        s1 = si_plus1
        si=binary_array_to_int(s1)
    
    print("E2 duration:", t2-t1)
    key = aes_key_from_seed(s1)
    #print("s1 in the key = aes_key_from_seed(s1):", s1)
    print("key(of encrypt):", key)
    Z = aes_encrypt(S, key)  # Encrypt each binary string in S individually
    print("PUF duration: ", ttt-tt)
    return s0, Z, H, key


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
def E2(seed, taps, n, L):
    state = seed  # Initial state of the LFSR
    output = []  
    for j in range(L):
        vector = 0  # Reset vector for each new LFSR output
        for bit_position in range(n):
            next_bit = 0
            # Calculate the feedback bit
            for t in taps:
                if t <= n:  # Ensure tap positions do not exceed the state width
                    next_bit ^= (state >> (n - t)) & 1
            state = ((state << 1) | next_bit) & ((1 << n) - 1)
           # vector = (vector << 1) | next_bit  # Update vector with the new bit at the correct position
        output.append(state)  # Append the final vector after all bits are processed
    return output

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

def Puz_Sol_Noisy_PUF(N, B, lambda_, taps, initial_seed, puf_parameter, Z, helper_data, T_threshold):

    bound=((lambda_**2)/2)*0.75
    si = np.array(list(bin(initial_seed)[2:].zfill(lambda_)), dtype=int)
    
    for i in range(N):
        ss = E2(initial_seed, taps, lambda_, B) 
        si_subseeds = [integer_to_binary_array(vector, lambda_) for vector in ss]
        min_count = float('inf')
        selected_j = 0
        L=lambda_
        print("current N inside the sol:", i)
        for j in range(B):
            cc=E2(ss[j], taps, lambda_, L)
            ci= [integer_to_binary_array(vector, lambda_) for vector in cc]
            count=0
            #count = sum(Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k]) for k in range(lambda_))
            for k in range(lambda_):
                count+=Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k])
                # print("helper_data ", i*(lambda_)+k, ": ", helper_data[i*(lambda_)+k])
            hdd=[]
            print("count:", count)
            if count < bound and count<min_count:
                print("yes!")
                
                min_count=count
                for k in range (lambda_):
                    hd=Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k])
                    #print("hd:", hd)
                    if hd<=(T_threshold*lambda_):                      
                        si[k]=1
                    else:
                        si[k]=0
                    hdd.append(hd)
                # if (si==s1).all() :
                #     print("True si founded!!")
                #     print("Now, the count is: ", count)
                #     print("si:",si)

                #print("hdd: ", hdd)
                #print("any si :", si)
                break

                #min_count = count
                #selected_j = j
        #initial_seed = int(''.join(map(str, si_subseeds[selected_j])), 2)
        initial_seed = int(''.join(map(str, si)), 2)

    # Decrypt the solution using the last valid seed

    key = aes_key_from_seed(si)
    decrypted_solution = aes_decrypt(Z, key)
    
    print("si in the key = aes_key_from_seed(si):", si)
    print("key(of decrypt):", key)


    if isinstance(decrypted_solution, bytes):
        # If the output is bytes, convert it into a format similar to `S`
        # Assuming each 'si' in `S` is a binary string of length `n`, split the decrypted bytes accordingly
        decrypted_solution = ''.join(format(byte, '08b') for byte in decrypted_solution)  # Convert bytes to binary string
        
        S_sol = [decrypted_solution[i:i+n] for i in range(0, len(decrypted_solution), n)]
    else:
        # If it's already a string, split it into list if needed
        print("No!, it's already a string ")
        S_sol = decrypted_solution

    return S_sol


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


####------------------------------------------------------------------------------------------------------#
#### Parameters:
t=150
#tc=0.0000019941329956054688 #seconds
#tc=0.000004681343203978919
tc=0.0000042812264110301671
tc=0.022
# tc=1.4
evaluations=1
e=t*0.1
p=0.95
B_min=5
T_threshold=0.3
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
    'sigma_noise': 0.1,
    'seed': 42,
    'vote_count': 1,
    'bias': None
}

# Initialize the solution set S
S = []
####------------------------------------------------------------------------------
start_time = time.time()
h, N, B, p_real, sig_real, mu, best_value, e_verification=opt(t, tc, e, p, B_min)
if isinstance(h, np.ndarray) and h.size == 1:
            h = h.item()  # Convert single-item array to scalar
if isinstance(N, np.ndarray) and N.size == 1:
            N2 = N.item()  # Convert single-item array to scalar
if isinstance(B, np.ndarray) and B.size == 1:
            B2 = B.item()  # Convert single-item array to scalar


L=round(2*h) # L is the Number of vectors in the solution set
N2=round(N2)
B2=round(B2)
print("#----------------------------------#")
print("h_min", -norm.ppf((1 - p) / 2))
print("h_tuned: ", h )
print("N2: ", N2)
print("B : ", B )
print("B2: ", B2)
print("e", e)
print("#----------------------------------#")
# Generate each vector si and add to the solution set S
for i in range(L):
    # Generate a random n-bit number and convert to binary string, padded with zeros
    si = bin(random.getrandbits(n))[2:].zfill(n)
    S.append(si)

gen_duration=0
sol_duration=0
x=0
B2=10
print("lambda_:",lambda_)
###------------
def test_reliability(puf_instance, puf_parameters, num_trials=100, num_challenges=50, challenge_length=128, noise_level=0.1):
    """
    Test the reliability of a PUF instance by introducing random noise to the challenges.
    :param puf_instance: The PUF instance to test.
    :param num_trials: Number of trials to perform for each challenge.
    :param num_challenges: Number of random challenges to generate.
    :param challenge_length: The length of each challenge in bits.
    :param noise_level: The probability of a bit flip (noise).
    :return: A dictionary containing the average reliability score and individual scores.
    """
    reliability_scores = []
    random_state = np.random.RandomState(seed=42)  # Ensuring reproducibility

    # Generate random challenges
    challenges = [random_state.randint(0, 2, size=(challenge_length,)) for _ in range(num_challenges)]

    for challenge in challenges:
        base_response = puf_instance(challenge, puf_parameters)  # Get the base response without noise
        consistent_count = 0

        for _ in range(num_trials):
            # Simulate noise by flipping some bits in the 
            #print("random_state.rand(challenge_length):  ",random_state.rand(challenge_length))
            noise = random_state.rand(challenge_length) < noise_level
            #print("noise:", noise)
            noisy_challenge = np.where(noise, 1-challenge, challenge)
            noisy_response = puf_instance(noisy_challenge, puf_parameters)

            # Check if the response to the noisy challenge is the same as the base response
            if np.array_equal(base_response, noisy_response):
                consistent_count += 1

        # Calculate the reliability for this challenge
        reliability = consistent_count / num_trials
        reliability_scores.append(reliability)
        print("consistent_count:", consistent_count)
    # Calculate average reliability across all challenges
    average_reliability = np.mean(reliability_scores)

    return {
        "average_reliability": average_reliability,
        "individual_scores": reliability_scores
    }

# Usage within your script
puf_parameters = {  
    'n': 64,
    'k': 4,
    'weight_array': np.random.randn(4, 64),
    'transform': lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2),
    'combiner': lambda x: np.prod(x, axis=1),
    'sigma_noise': 1.01,
    'seed': 42,
    'vote_count': 1,
    'bias': None
}

# Define a wrapper function for your specific PUF instance
def puf_instance(challenge, puf_parameters):
    return XOR_PUF(challenge, puf_parameters)

# Test the reliability
# reliability_results = test_reliability(puf_instance, puf_parameters)
# print("Average Reliability Score:", reliability_results["average_reliability"])


###-------------

for k in range (evaluations):
    time1 = time.time()
    #GENERATE PUZZLE:
    c0, Z, helper_data, key = Puz_Gen(N2, B2, S, lambda_, puf_parameter)
    #print("helper_data:",helper_data)
    time2 = time.time()
    gen_duration+=(time2-time1)
    print("Z:",Z)
    time3 = time.time()
    S_sol=Puz_Sol_Noisy_PUF(N2, B2, lambda_, taps, c0, puf_parameter, Z, helper_data, T_threshold)
    time4 = time.time()
    print("Puz_Gen function duration:", time2-time1)
    print("Puz_Sol_Noisy_PUF function duration:", time4-time3)
    print("tc*(L+2+2*N2): ", tc*(L+2+2*N2))
print("S  : ", S)
print("S_Sol: ", S_sol)
if solution_equality(S, S_sol):
    print("The solved solution is the same as locked solution.")
else:
    print("The solved solution is not the same as locked solution!!")
