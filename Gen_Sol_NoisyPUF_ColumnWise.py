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

        ss = E3(si, taps, lambda_, B, True) 
        si = [integer_to_binary_array(vector, lambda_) for vector in ss]
        j = random.randint(0, B-1)
        si_j = ss[j]
        t1=time.time()
        cc = E3(si_j, taps, lambda_, lambda_, True)
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

def E3(seed, taps, n, L, sel):
    state = seed  # Initial state of the LFSR
    state_all = []  
    output = [] 
    for j in range(L):
        for bit_position in range(n):
            next_bit = 0
            # Calculate the feedback bit
            for t in taps:
                if t <= n:  # Ensure tap positions do not exceed the state width
                    next_bit ^= (state >> (n - t)) & 1
            state = ((state << 1) | next_bit) & ((1 << n) - 1)
        state_all.append(state)  # Append the final vector after all bits are processed
    if sel==True :
         output=state_all 
    else: 
         output=state
    return output


def E4(seed, taps, n, k):
    """
    Computes only the k-th output (c_{i,k}) from the LFSR instead of generating all L values.
    
    :param seed: Initial seed value (integer).
    :param taps: List of tap positions for LFSR.
    :param n: Bit-width of the LFSR.
    :param k: Index of the required output (instead of generating all L outputs).
    :return: The k-th value of the LFSR sequence.
    """
    state = seed  # Initialize LFSR state
    state_all = []
    for j in range(k + 1):  # Run the LFSR until reaching the k-th value
        next_bit = 0
        for t in taps:
            if t <= n:  # Ensure valid tap positions
                next_bit ^= (state >> (n - t)) & 1
        state = ((state << 1) | next_bit) & ((1 << n) - 1)  # Update LFSR state
    return state  # Return only the required k-th output


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
####------------Puzzle solving---Row-wise------------------------------------------------------------#

def Puz_Sol_Noisy_PUF_modified(N, B, lambda_, taps, initial_seed, puf_parameter, Z, helper_data, T_threshold):

    bound=((lambda_**2)/2)*0.75
    si = np.array(list(bin(initial_seed)[2:].zfill(lambda_)), dtype=int)
    # Compute R from sigma_noise
    sigma_noise = puf_parameter['sigma_noise']
    R_max = lambda_ / 2
    kappa = 5  # Scaling factor for response to noise
    R = R_max * (1 - np.exp(-kappa * sigma_noise))
    print("R : ",R)
    L_opt = ((B - 1) / np.log(2) - lambda_) / (B - 1)
    print("L_opt : ", L_opt)
    count_puf=0
    for i in range(N):
        ss = E2(initial_seed, taps, lambda_, B) 
        si_subseeds = [integer_to_binary_array(vector, lambda_) for vector in ss]
        min_count = float('inf')
        zero_streak=0
        L=lambda_
        n=lambda_/12 #an arbitrary value!!for now
        print("current N inside the sol:", i)
        for j in range(B):
            cc=E2(ss[j], taps, lambda_, L)
            ci= [integer_to_binary_array(vector, lambda_) for vector in cc]
            count=0
            #count = sum(Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k]) for k in range(lambda_))
            #Derive Li from R and i:
            # Compute dynamic Li
            L_min=5
            Li = round(R * (1 - i / N)) + L_min  # Ensure Li is at least 1
            #Li=15
            #print("Li : ",Li)
            bound_Li=Li*lambda_*0.75/2
            #print("bound_Li : ", bound_Li)

            for k in range(Li):
                count+=Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k])
                count_puf+=1
                # print("helper_data ", i*(lambda_)+k, ": ", helper_data[i*(lambda_)+k])
            hdd=[]
            #print("count:", count)
            if count < bound_Li and count<min_count:
                #print("yes!")
                
                min_count=count
                #for k in range (0,lambda_,1):
                for k in range (lambda_):
                    hd=Hamming_Distance(XOR_PUF(ci[k], puf_parameter), helper_data[i*(lambda_)+k])
                    count_puf+=1
                    
                    if hd<=(T_threshold*lambda_):                      
                        si[k]=1
                        zero_streak=0
                    else:
                        si[k]=0
                        zero_streak+=1
                        if zero_streak>n :
                            print("zero_streak skip!")
                            print("hd:", hd)
                            print("helper_data ", i*(lambda_)+k, ": ", helper_data[i*(lambda_)+k])

                            #break
                    hdd.append(hd)
                break
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

    return S_sol, count_puf

####-------Puzzle solving---Column-wise----------------------------------------------------#
### Both Puz_Sol_Noisy_PUF_ColumnWise and Puz_Sol_Noisy_PUF_ColumnWise2 works correctly. They're almost the same.
def Puz_Sol_Noisy_PUF_ColumnWise(N, B, lambda_, taps, initial_seed, puf_parameter, Z, helper_data, T_threshold):

    bound=((lambda_**2)/2)*0.75
    si = np.array(list(bin(initial_seed)[2:].zfill(lambda_)), dtype=int)
    count_puf=0
    for i in range(N):
        ss = E3(initial_seed, taps, lambda_, B, True) 
        si_subseeds = [integer_to_binary_array(vector, lambda_) for vector in ss]
        B_value=0
        B_found=False
        print(f"Iteration {i}: Computing column-wise solving...")

        for k in range(lambda_):
            valid_found = False
            #print("current k is ", k)
            if B_found==True:
                ci_k=E3(ss[B_value], taps, lambda_, k, False)
                ci_k_bin = integer_to_binary_array(ci_k, lambda_)
                hd=Hamming_Distance(XOR_PUF(ci_k_bin, puf_parameter), helper_data[i*(lambda_)+k])
                count_puf+=1
                if hd<=(T_threshold*lambda_):
                    si[k]=1
                else:
                    si[k]=0
                
            if B_found==False:
                for j in range(B):
                    ci_k=E3(ss[j], taps, lambda_, k, False)
                    ci_k_bin = integer_to_binary_array(ci_k, lambda_)
                    hd=Hamming_Distance(XOR_PUF(ci_k_bin, puf_parameter), helper_data[i*(lambda_)+k])
                    count_puf+=1
                    # print("helper_data ", i*(lambda_)+k, ": ", helper_data[i*(lambda_)+k])
                    #print("j is ", j)   
                    if hd<=(T_threshold*lambda_):                      
                        si[k]=1
                        valid_found=True
                        B_value=j
                        B_found=True
                        print("valid found! j is ", j)
                        break

                if not valid_found:  # If no valid 1 found, assign 0
                    print("valid not found!!!")
                    si[k] = 0
            

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

    return S_sol, count_puf

def Puz_Sol_Noisy_PUF_ColumnWise2(N, B, lambda_, taps, initial_seed, puf_parameter, Z, helper_data, T_threshold):

    bound=((lambda_**2)/2)*0.75
    si = np.array(list(bin(initial_seed)[2:].zfill(lambda_)), dtype=int)

    for i in range(N):
        ss = E3(initial_seed, taps, lambda_, B, True) 
        si_subseeds = [integer_to_binary_array(vector, lambda_) for vector in ss]
        B_value=0
        B_found=False
        print(f"Iteration {i}: Computing column-wise solving...")

        for k in range(lambda_):
            valid_found = False
            # print("current k is ", k)
            if B_found==True:
                ci_k=E3(ss[B_value], taps, lambda_, k, False)
                ci_k_bin = integer_to_binary_array(ci_k, lambda_)
                hd=Hamming_Distance(XOR_PUF(ci_k_bin, puf_parameter), helper_data[i*(lambda_)+k])
                if hd<=(T_threshold*lambda_):
                    si[k]=1
                    # print(f"Reusing B_value={B_value} for k={k}, valid")
                    continue
                else:
                    si[k]=0
                    continue
                          
            for j in range(B):
                ci_k=E3(ss[j], taps, lambda_, k, False)
                ci_k_bin = integer_to_binary_array(ci_k, lambda_)
                hd=Hamming_Distance(XOR_PUF(ci_k_bin, puf_parameter), helper_data[i*(lambda_)+k])
                # print("helper_data ", i*(lambda_)+k, ": ", helper_data[i*(lambda_)+k])
                #print("j is ", j)   
                if hd<=(T_threshold*lambda_):                      
                    si[k]=1
                    valid_found=True
                    B_value=j
                    B_found=True
                    # print("valid found! j is ", j)
                    break

            if not valid_found:  # If no valid 1 found, assign 0
                # print(f"Valid not found for k={k}, assigning 0")
                si[k] = 0
                B_found=False
            

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


def Puz_Sol_Noisy_PUF_ColumnWise_Slow(N, B, lambda_, taps, initial_seed, puf_parameter, Z, helper_data, T_threshold):

    si = np.array(list(bin(initial_seed)[2:].zfill(lambda_)), dtype=int)
    for i in range(N):
        ss = E3(initial_seed, taps, lambda_, B, True) 
        si_subseeds = [integer_to_binary_array(vector, lambda_) for vector in ss]
        print(f"Iteration {i}: Computing column-wise solving...")

        for k in range(lambda_):  # Iterate over columns first
            valid_found = False
            for j in range(B):  # Iterate over sub-seeds
                ci_k = E3(ss[j], taps, lambda_, k,False)  # Compute only required c_{i,k}
                ci_k_bin = integer_to_binary_array(ci_k, lambda_)
                hd = Hamming_Distance(XOR_PUF(ci_k_bin, puf_parameter), helper_data[i * lambda_ + k])
                if hd <= (T_threshold * lambda_):  # If within threshold, assign 1
                    si[k] = 1
                    valid_found = True
                    print("valid found! j is ", j)
                    break  # Early exit when valid j is found

            if not valid_found:  # If no valid 1 found, assign 0
                si[k] = 0
            
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

####-----------Run the Puzzle generator and solver--------------------------------------------#
#### Parameters:
t=150*100
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
N2=5
B2=500
print("lambda_:",lambda_)

for k in range (evaluations):
    time1 = time.time()
    #GENERATE PUZZLE:
    c0, Z, helper_data, key = Puz_Gen(N2, B2, S, lambda_, puf_parameter)
    #print("helper_data:",helper_data)
    time2 = time.time()
    gen_duration+=(time2-time1)
    print("Z:",Z)
    time3 = time.time()
    S_sol, count_puf=Puz_Sol_Noisy_PUF_ColumnWise(N2, B2, lambda_, taps, c0, puf_parameter, Z, helper_data, T_threshold)
    #S_sol, count_puf=Puz_Sol_Noisy_PUF_modified(N2, B2, lambda_, taps, c0, puf_parameter, Z, helper_data, T_threshold)
    time4 = time.time()
    print("Puz_Gen function duration:", time2-time1)
    print("Puz_Sol_Noisy_PUF function duration:", time4-time3)
    print("count_puf: ", count_puf)
    print("tc*(L+2+2*N2): ", tc*(L+2+2*N2))
print("S  : ", S)
print("S_Sol: ", S_sol)
if solution_equality(S, S_sol):
    print("The solved solution is the same as locked solution.")
else:
    print("The solved solution is not the same as locked solution!!")

###=====Start Reliability evaluation=================================>
### Measures robustness of the PUF to challenge corruption: 
#### But there is a problem here each time a new puf is instantiated for a new challenge!
def test_robustness(puf_instance, puf_parameters, num_trials=100, num_challenges=50, challenge_length=128, noise_level=0.0004):
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
## Compute XORArbiterPUF Reliability for different sigma_noise values:
def test_reliability(lambda_, sigma_list, base_params, num_trials=100, num_challenges=50):
    reliability_results = {}
    random_state = np.random.RandomState(seed=42)
    challenges = [random_state.randint(0, 2, size=(lambda_,)) for _ in range(num_challenges)]

    for sigma in sigma_list:
        # Copy and update parameters
        puf_params = base_params.copy()
        puf_params['sigma_noise'] = sigma

        # Create PUF object once (for this sigma)
        xor_arbiter_puf = XORArbiterPUF(
            puf_params['n'],
            puf_params['k'],
            puf_params['weight_array'],
            puf_params['transform'],
            puf_params['combiner'],
            puf_params['sigma_noise'],
            puf_params['seed'],
            puf_params['vote_count'],
            puf_params['bias']
        )

        def fixed_eval(challenge):
            # Reuse the constructed PUF object
            return xor_arbiter_puf.eval(challenge.reshape(1, -1)).flatten()

        score_list = []
        for challenge in challenges:
            base_response = fixed_eval(challenge)
            consistent_count = 0
            for _ in range(num_trials):
                noisy_response = fixed_eval(challenge)
                if np.array_equal(base_response, noisy_response):
                    consistent_count += 1
            score_list.append(consistent_count / num_trials)

        average_reliability = np.mean(score_list)
        reliability_results[sigma] = average_reliability
        print(f"[σ = {sigma:.4f}] → Reliability = {average_reliability:.4f}")

    return reliability_results

# Usage within your script
puf_parameters = {  
    'n': 64,
    'k': 4,
    'weight_array': np.random.randn(4, 64),
    'transform': lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2),
    'combiner': lambda x: np.prod(x, axis=1),
    'sigma_noise': 0.1,
    'seed': 42,
    'vote_count': 1,
    'bias': None
}

# Define a wrapper function for your specific PUF instance
def puf_instance(challenge, puf_parameters):
    return XOR_PUF(challenge, puf_parameters)

# For evaluationg the reliability of XORArbiterPUF over different sigma_noise values, 
# we can add the noises to the sigma_list and run the test_reliability func:
sigma_list = np.linspace(0.01, 0.2, 3)
reliability_results1 = test_reliability(puf_parameters['n'], sigma_list, puf_parameters)

for sigma, reliability in reliability_results1.items():
    print(f"σ = {sigma:.3f} → Reliability = {reliability:.4f}")

#challenge_robustness_results = test_robustness (puf_instance, puf_parameters)

###=====End Reliability evaluation=================================<