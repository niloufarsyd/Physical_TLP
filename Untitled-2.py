# def cal_NB(t, tc, h, e):
#     """
#     Calculate parameters N and B based on provided formulae.
    
#     :param t: Desired unlocking time (years or appropriate time unit)
#     :param tau: Time to evaluate one PUF (same time units as t)
#     :param h: Soundness parameter (dimensionless)
#     :param epsilon: Error tolerance in time units (same as t and tau)
#     :return: Tuple (N, B)
#     """
#     # Calculate N
#     N = (4 * h**2 * t**2) / (3 * e**2)
    
#     # Calculate B
#     B = (3 * (e**2)) / (2 * (h**2) * t * tc)

#     return int(N)*int(B)

# # Example parameters
# t = 100  # 100 years
# tau = 0.000000000000000317  # 10 nanoseconds or 3.17*10^-16 years
# h = 4  # Soundness parameter
# e = 1 / 365  # 1 day in years

# # Calculate N and B
# NB = cal_NB(t, tau, h, e)
 
# print(f" tc={tau}, e={e},  N = {NB}")
# ##---------------------------------------------------------------------------------------------------
# import numpy as np
# import matplotlib.pyplot as plt
# from scipy.stats import norm
# import time
# import os
# import hashlib
# import random
# start_time0 = time.time()
# # Define the range of h values
# h_values = np.linspace(0, 5, 100)
# # Calculate p values using the formula p = 1 - 2 * CDF(-h)
# p_values = 1 - 2 * norm.cdf(-h_values)

# # Create the plot
# plt.figure(figsize=(8, 5))
# plt.plot(h_values, p_values, label='p = 1 - 2 * CDF(-h)')
# plt.title('Probability p based on h')
# plt.xlabel('h value')
# plt.ylabel('Probability p')
# plt.grid(True)
# plt.legend()
# plt.show()



# def puf(input_seed):
#     """Simulate PUF response using a hash function."""
#     return hashlib.sha256(input_seed.encode()).hexdigest()
# lambda_=256

# start_time = time.time()
# initial_seed = os.urandom(lambda_ // 8).hex()
# x=1000
# for i in range (x):
#     r=puf(initial_seed)

# end_time = time.time()
# duration = end_time - start_time
# print("start time0: ", start_time0)
# print("start time: ", start_time)
# print("end time: ", end_time)
# print(f"The function took {duration} seconds to complete.")
# ##---------------------------------------------------------------------------------------------------

# import numpy as np
# from PUF.XorArbiterPuf import XorArbiterPuf
# import os
# import random
# import hashlib

# def generate_seed_from_bytes(bytes_data):
#     hash_object = hashlib.sha256(bytes_data)
#     # Take the first 4 bytes from the hash digest and convert to int
#     return int.from_bytes(hash_object.digest()[:4], 'big')

# def generate_challenges(seed_challenge, num_challenges, num_stages, num_xors):
#     seed = generate_seed_from_bytes(seed_challenge)
#     np.random.seed(seed)  # Use the hashed seed
#     base_challenge = np.random.randint(0, 2, num_stages)  # Generate a random initial challenge

#     challenges = np.tile(base_challenge, (num_challenges, 1))
#     for i in range(num_challenges):
#         flip_indices = np.random.choice(num_stages, size=int(num_stages * 0.1), replace=False)  # Flip 10% of bits
#         challenges[i, flip_indices] ^= 1  # XOR to flip the bits

#     config = {
#         'num_stages': num_stages,
#         'num_xors': num_xors
#     }
#     xor_puf = XorArbiterPuf(config)
#     responses = [xor_puf.generate_response(challenge) for challenge in challenges]

#     return challenges, responses



# lambda_=32

# num_challenges=6
# num_stages=64
# num_xors=3
# initial_seed = os.urandom(lambda_//8 )  # Random seed c0 generated inside the algorithm #16 bytes # the // 8 converts bits to bytes
# seed_challenge=initial_seed
# [c, r]=generate_challenges(seed_challenge, num_challenges, num_stages, num_xors)
# ##---------------------------------------------------------------------------------------------------
import numpy as np
from PUF.XorArbiterPuf import XorArbiterPuf
from PUF.base import XORPUF, LTFArray  # Adjust this import according to your project structure
import os
import hashlib

# Re-attempting the plot generation

# Define parameters
lambda_ = 100  # Security parameter
B = 10  # Expansion function parameter

# Define the solving time function
def T(L, lambda_, B):
    return (1/2)**L * (lambda_ - L + B * L)

# Generate values for L
L_values = np.linspace(1, lambda_, 1000)  # L ranges from 1 to lambda_
T_values = T(L_values, lambda_, B)

# Plot the function
plt.figure(figsize=(8, 5))
plt.plot(L_values, T_values, label=r"$T(L) = (1/2)^L \cdot (\lambda - L + B \cdot L)$", color='b')
plt.axvline(x=lambda_/2, linestyle='--', color='r', label=r"$L_{\text{opt}}$ candidate")
plt.xlabel("L")
plt.ylabel("Solving Time T(L)")
plt.title("Solving Time Function $T(L)$ vs. $L$")
plt.legend()
plt.grid()
plt.show()

# def generate_seed_from_bytes(bytes_data):
#     hash_object = hashlib.sha256(bytes_data)
#     return int.from_bytes(hash_object.digest()[:4], 'big')

# def generate_challenges(seed_challenge, num_challenges, num_stages, num_xors):
#     seed = generate_seed_from_bytes(seed_challenge)
#     np.random.seed(seed)  # Use the hashed seed
#     base_challenge = np.random.randint(0, 2, num_stages)  # Generate a random initial challenge

#     challenges = np.tile(base_challenge, (num_challenges, 1))
#     for i in range(num_challenges):
#         flip_indices = np.random.choice(num_stages, size=int(num_stages * 0.1), replace=False)  # Flip 10% of bits
#         challenges[i, flip_indices] ^= 1  # XOR to flip the bits

#     config = {
#              'num_stages': num_stages,
#              'num_xors': num_xors
#          }
#     # Create multiple PUF simulations
#     puf_simulations = [XorArbiterPuf(**config) for _ in range(num_xors)]
    
#     # Combine them using XORPUF
#     xor_puf = XORPUF(puf_simulations)
#     responses = xor_puf.eval(challenges)

#     return challenges, responses

# lambda_ = 32
# num_challenges = 6
# num_stages = 64
# num_xors = 3
# initial_seed = os.urandom(lambda_ // 8)  # 4 bytes for the seed
# seed_challenge = initial_seed
# [c, r] = generate_challenges(seed_challenge, num_challenges, num_stages, num_xors)
# print("r:", r)
import numpy as np
from numpy.random import default_rng

# Assume the classes LTFArray and XORPUF are defined as provided in your message

# Function to create random weights for LTFArrays
def create_weights(num_stages, num_functions, seed):
    rng = default_rng(seed)
    return rng.normal(0, 1, size=(num_functions, num_stages))
weights=[]
ltf=[]
# Create two LTFArray instances with random weights
for i in range (5):
    weights.append(create_weights(64, 4, seed=i))  
    ltf.append(LTFArray(weight_array=weights[i], transform=LTFArray.transform_id, combiner=LTFArray.combiner_xor))

xor_puf = XORPUF(simulations=[ltf])
# weights1 = create_weights(64, 4, seed=1)  # 64 stages, 4 LTFs
# weights2 = create_weights(64, 4, seed=2)
# ltf1 = LTFArray(weight_array=weights1, transform=LTFArray.transform_id, combiner=LTFArray.combiner_xor)
# ltf2 = LTFArray(weight_array=weights2, transform=LTFArray.transform_id, combiner=LTFArray.combiner_xor)

# Combine LTFs into an XORPUF
#xor_puf = XORPUF(simulations=[ltf1, ltf2])

# Generate some challenges
challenges = np.random.randint(0, 2, size=(10, 64))  # 10 challenges, 64-bit each

# Evaluate the XORPUF with the challenges
responses = xor_puf.eval(challenges)

print("Challenges:\n", challenges)
print("Responses:\n", responses)

