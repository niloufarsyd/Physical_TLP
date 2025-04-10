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

#from PUF import XorArbiterPuf
####-----------tuning soundness parameter h:-------------------------------------#
def create_objective_function(t, tc, e):
    # Constant parameters: t, tc, e, p_min
    def objective_function(params):
        h = params
        # Example evaluation using constants and parameters
        N = 4 * h**2 * t**2 / (3 * e**2)
        B = 3 * e**2 / (2 * h**2 * t * tc)
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
    options = {'bounds': [h_min, 5], 'seed': 1234}
    es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
    es.optimize(objective_function)
    # Access the best solution after the optimization
    h_tuned= es.result.xbest  # Best solution found
    best_value = es.result.fbest  # Objective value of the best solution

    p_real=1-2*(norm.cdf(-(h_tuned)))
    
    N = 4 * (h_tuned)**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * (h_tuned)**2 * t * tc)
    sig_real=(np.sqrt(N/12))*(B)*tc
    mu=(N*B)/2
    #sig=(np.sqrt(N/12))*(B)*tc
    ee=2*sig_real*h_tuned
    return h_tuned, N, B, p_real, sig_real, mu, best_value, ee

####-----------PUF: ------------------------------------------------------------------#
###--------------A HASH function as a PUF:
def puf(input_seed):
    """Simulate PUF response using a hash function."""
    return hashlib.sha256(input_seed.encode()).hexdigest()

###-------------Or using the simulated XOR APUF:
# Function to expand an n-bit challenge to a (64*n)-bit challenge using a PRNG
# def expand_challenge(seed_challenge: np.ndarray, n: int, seed: int) -> np.ndarray:
#     rng = np.random.default_rng(seed)
#     print("n:", n)
#     expanded_bits  = rng.integers(0, 2, (n * 64,))
    

#     # XOR the seed_challenge with the expanded_bits

#     seed_challenge_flat = np.tile(seed_challenge, n * 64 // len(seed_challenge) + 1)[:n * 64]
    
#     expanded_challenge = np.bitwise_xor(expanded_bits, seed_challenge_flat)
# #    j=n//64
#     print("expanded_bits :",expanded_bits)
#     print("seed_challenge_flat :",seed_challenge_flat)
#     print("expanded_challenge:",expanded_challenge)

#     # for i in range (j):
#     #     x = np.bitwise_xor(expanded_challenge[64*i:64*i+63], seed_challenge)
#     #     expanded_challenge[64*i:64*i+63]=x

      
#     return expanded_challenge

# Function to generate n-bit responses from an n-bit challenge
def XOR_PUF(chal, puf_parameter):
    #seed_challenge = chal
    #n = len(seed_challenge[0])
    n=256
    m=64
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
         chunks[i,:]=seed_challenge[i * 64:(i + 1) * 64]

    #chunks = [seed_challenge[i * 64:(i + 1) * 64] for i in range(num_chunks)]


    # Generate a (64*n)-bit expanded challenge vector
    #expanded_challenge = expand_challenge(seed_challenge, n, seed)

    # Split the expanded challenge into n segments of 64 bits each
    #challenge_segments = np.split(expanded_challenge, n)
 
    # Initialize an array to store the responses
    responses = np.zeros(n, dtype=int)
    
    # Create the PUF instance
    xor_arbiter_puf = XORArbiterPUF(
        64,  # The PUF has 64 stages
        puf_parameter['k'],
        puf_parameter['weight_array'],
        puf_parameter['transform'],
        puf_parameter['combiner'],
        puf_parameter['sigma_noise'],
        puf_parameter['seed'],
        puf_parameter['vote_count'],
        puf_parameter['bias']
    )
    time.sleep(2)  # Example: wait for 2 seconds
    # Evaluate each segment and collect the responses
    for i in range (1, m):
        np.random.seed(seedd+i)
        seed_v=np.random.randint(0, 2, (1,m), dtype=int)
        # for index, chunk in enumerate(chunks):
        #     c=np.bitwise_xor(chunk,seed_v)
        #     responses(index*m+i)=xor_arbiter_puf.eval(c)
        for j in range (num_chunks):

            c=np.bitwise_xor(chunks[j,:],seed_v)
            responses[j*m+i,]=xor_arbiter_puf.eval(c)
    
    return responses
# def XOR_PUF(chal, puf_parameter):
#     seed_challenge = chal
#     #n = len(seed_challenge[0])
#     n=256
#     seed = puf_parameter['seed']
#     print("len(seed_challenge):",n)
#     # Generate a (64*n)-bit expanded challenge vector
#     expanded_challenge = expand_challenge(seed_challenge, n, seed)
#     print("seed_challenge:",seed_challenge)
#     print("expanded_challenge:",expanded_challenge)
#     print("len(expanded_challenge):",len(expanded_challenge))
#     # Split the expanded challenge into n segments of 64 bits each
#     challenge_segments = np.split(expanded_challenge, n)
#     print("challenge_segments:",challenge_segments)
#     # Initialize an array to store the responses
#     responses = np.zeros(n, dtype=int)
    
#     # Create the PUF instance
#     xor_arbiter_puf = XORArbiterPUF(
#         64,  # The PUF has 64 stages
#         puf_parameter['k'],
#         puf_parameter['weight_array'],
#         puf_parameter['transform'],
#         puf_parameter['combiner'],
#         puf_parameter['sigma_noise'],
#         puf_parameter['seed'],
#         puf_parameter['vote_count'],
#         puf_parameter['bias']
#     )
#     time.sleep(2)  # Example: wait for 2 seconds
#     # Evaluate each segment and collect the responses
#     for i, segment in enumerate(challenge_segments):
#         print("segment ", i,": ", segment)
#         response = xor_arbiter_puf.eval(segment.reshape(1, -1))
#         responses[i] = response
    
#     return responses
     
####-----------Generate Puzzle: ------------------------------------------------------------------#
def gen_puz(N, B, L, lambda_, S, puf_parameter):
    initial_seed = os.urandom(lambda_ // 8).hex()

    lambda_ = 256  # Number of bits
    num_bytes = lambda_ // 8  # Convert bits to bytes
    initial_seed = os.urandom(num_bytes).hex()  # Generate random bytes and convert to hex

    # Convert the hex string to a binary string
    binary_seed = bin(int(initial_seed, 16))[2:].zfill(num_bytes * 8)
    Z = []
    helper_data = []
    challenges = []
    challenges.append(binary_seed)
    responses = []
    # print("initial_seed in gen_puz:",initial_seed)
    # print("challenges in gen_puz:",challenges)
    for i in range(1, N + 2):
        #print("step1 in gen_puz and round i=", i)
        #print("challenges[i-1]:", challenges[i-1])
        t1=time.time()
        response = XOR_PUF(challenges[i-1], puf_parameter)
        t2=time.time()
        t3=t2-t1
        #print("response (inside gen_puz):" ,response)
        responses.append(response)
        #print("step2 in gen_puz and round i=", i)
        helper_data.append(XOR_PUF(response, puf_parameter))
        
        k = random.randint(0, B-1) #Generate a k from 0 to B-1
        # packed_response = np.packbits(response)
        # integer_response = int.from_bytes(packed_response, byteorder='big') # Convert the packed bytes to an integer
        # ci_int=integer_response+k
        # ci=np.array(list(bin(ci_int)[2:].zfill(len(response))), dtype=int)
        #ci=response+ np.array(list(bin(k)[2:].zfill(len(response))), dtype=int)
        # print("ci_int: ", ci_int)
        # print("ci: ", ci)
        ci=np.bitwise_xor(responses[-1], np.array(list(bin(k)[2:].zfill(len(response))), dtype=int))
        challenges.append(ci)
    print("Puf duration:", t3)
    print("responses[-1]:",responses[-1])
    print("ki:", np.array(list(bin(k)[2:].zfill(len(response))), dtype=int))
    print("ci:", ci)
    
    for j in range(L):
        j_binary=responses[-1]+ np.array(list(bin(j)[2:].zfill(len(responses[-1]))), dtype=int)
        modified_response = (responses[-1] + j_binary) % 2
        puf_output=XOR_PUF(modified_response, puf_parameter)
        s_array=np.array(list(S[j]), dtype=int)

        #print("step3 in gen_puz and round j=", j)
        xor_output = np.bitwise_xor(puf_output  , s_array)
        Z.append(xor_output)
    
    return binary_seed, Z, helper_data

def sol_puz(initial_seed_sol, N, B, Z, H, puf_parameter):
    #challenges = [np.frombuffer(bytes.fromhex(initial_seed_sol), dtype=np.uint8)]
    challenges=[]
    challenges.append(initial_seed_sol)
    responses=[]
    response=XOR_PUF(challenges[0], puf_parameter)
    responses.append(response)
    S = []
    print("responses[0]:",responses[0])
    for i in range(1, N+1):
        for k in range(B):
            #ci = np.bitwise_xor(responses[-1], np.array([k]*len(response), dtype=np.uint8))
            ci = np.bitwise_xor(responses[-1], np.array(list(bin(k)[2:].zfill(len(response))), dtype=int))
            response = XOR_PUF(ci, puf_parameter)
            if np.array_equal(XOR_PUF(response, puf_parameter), H[i]):
                challenges.append(ci)
                responses.append(response)
                break
    
    for j in range(L):
        t4=time.time()
        xor_output = XOR_PUF(np.bitwise_xor(responses[-1], np.array([j]*len(responses[-1]), dtype=np.uint8)), puf_parameter)
        t5=time.time()
        t6=t5-t4
        S.append(np.bitwise_xor(xor_output, Z[j]))
    print("Puf duraction(sol):", t6)
    return S
####-----------Comapring the results:----------------------------------------------------------------#
def solution_equality(s1, s2):
    
    if len(s1) != len(s2):
        return False

    for v1, v2 in zip(s1, s2):
        if v1 != v2:
            return False

    return True
####------------------------------------------------------------------------------------------------------#
####------------------------------------------------------------------------------------------------------#
#### Parameters:
t=750
#tc=0.0000019941329956054688 #seconds
#tc=0.000004681343203978919
#tc=0.0000042812264110301671
tc=2.05
evaluations=3
e=t*0.1
p=0.95
B_min=5

n = 256  # Number of bits in each vector
lambda_ = n  # Security parameter


puf_parameter = {  
    'n': 64,  # num_stages in the PUF
    'k': 4,  # num_xors
    'weight_array': np.random.randn(4, 64),
    'transform': lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2),
    'combiner': lambda x: np.prod(x, axis=1),
    'sigma_noise': 0.01,
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
# N2=10
# B2=50
for k in range (evaluations):
    time1 = time.time()
    #GENERATE PUZZLE:
    c0, Z, helper_data = gen_puz(N2, B2, L, lambda_, S, puf_parameter)
    time2 = time.time()
    gen_duration+=(time2-time1)
    #SOLVE PUZZLE:
    time3 = time.time()
    S_sol = sol_puz(c0, N2, B2, Z, helper_data, puf_parameter)
    time4 = time.time()
    tt=time4-time3
    sol_duration+=(tt)
    print("tt:", tt)
    print("per gen function duration:", time2-time1)
    print("tc*(L+2+2*N2): ", tc*(L+2+2*N2))
    if (tt)<(t+(e)) and (tt)>(t-(e)) :
         x+=1
         print("k:",k)
xx=x/evaluations
# each Zi has 256-bits
# each Si has n-bits
# each helper_data element has 256 bits or 64 hex


# Print the solution set
print("#----------------------------------#")
# for index, vector in enumerate(S):
#     print(f"S{index}:", vector)


# for index, vector in enumerate(Z):
#     print(f"Z{index}:", vector)
# print("#----------------------------------#")  
# for index, vector in enumerate(S_sol):
#     print(f"S{index} (solved):", vector)


if solution_equality(S, S_sol):
    print("The solved solution is the same as locked solution.")
else:
    print("The solved solution is not the same as locked solution!!")

print("time1: ", time1)
print("P :", p_real)
print("generation time: ", gen_duration)
print("solving time: ", sol_duration)
print("PUF duration: ", (time2-time1)/(L+2+2*(N2)))
print("PUF duration2: ", (gen_duration)/((L+2+2*N2)*(evaluations)))
print("x:",x)
print("xx:",xx)
