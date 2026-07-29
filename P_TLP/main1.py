import os
import hashlib
import random

##---------------------------------------------
# Parameters

n = 256  # Number of bits in each vector
h = 3  # Soundness parameter
L = h*2  # Number of vectors in the solution set
# Initialize the solution set S
S = []

# Generate each vector si and add to the solution set S
for i in range(L):
    # Generate a random n-bit number and convert to binary string, padded with zeros
    si = bin(random.getrandbits(n))[2:].zfill(n)
    S.append(si)

# Print the solution set
print("#----------------------------------#")
for index, vector in enumerate(S):
    print(f"S{index}:", vector)
##---------------------------------------------

def puf(input_seed):
    """Simulate PUF response using a hash function."""
    return hashlib.sha256(input_seed.encode()).hexdigest()

def gen_puz(lambda_, h, S):
    # Parameters based on lambda_ and h
    N = lambda_ // 16  # Example function of lambda_ for N
    L = h * 2          # Example function of h for L
    initial_seed = os.urandom(lambda_ // 8).hex()  # Random seed c0 generated inside the algorithm #16 bytes

    Z = []  # To store Z outputs
    helper_data = []  # To store helper data
    challenges=[]
    responses=[]
    challenges=[initial_seed]
    
    for i in range(1, N + 2):
        B = lambda_ // 4  # Example function of lambda_ for B
        responses.append(puf(challenges[i-1]))
        helper_data.append(puf(responses[i-1]))       
        # Randomly select k from [0, B-1] and use it to generate the next seed
        k = random.randint(0, B-1)  # Generate k randomly within the specified range
        challenges.append(responses[i - 1] + str(k))  # Use the response at index k to generate the next seed

    for j in range(L):
        xor_output = int(puf(responses[-1] + str(j)), 16) ^ int(S[j], 2)
        Z.append(bin(xor_output)[2:].zfill(n))


    return initial_seed, N, B, Z, helper_data

# Parameters
lambda_ = n  # Security parameter
c0, N, B, Z, helper_data = gen_puz(lambda_, h, S)

# each Zi has 256-bits
# each Si has n-bits
# each helper_data element has 256 bits or 64 hex

print("#----------------------------------#")
print("Initial Seed (c0):", c0)

print("#----------------------------------#")
for index, vector in enumerate(Z):
    print(f"Z{index}:", vector)
print("#----------------------------------#")  
# for index, vector in enumerate(Z):
#     print(f"helper_data{index}:", vector)

## ---------------------------------------------PUZZLE SOLVING: ---------------------------------------------
# generate seed challenge :
initial_seed_s = os.urandom(lambda_ // 8).hex()  # Random seed c0 generated inside the algorithm #16 bytes

n=256
#h = 6  # Soundness parameter
lambda_ = n  # Security parameter
#N = lambda_ // 16  # Example function of lambda_ for N
#B = lambda_ // 4  # Example function of lambda_ for B
L = h * 2          # Example function of h for L

def sol_puz(initial_seed_sol, N, B, Z, H):
    challenges=[]
    responses=[]
    S=[]
    challenges=[initial_seed_sol]
    responses.append(puf(challenges[0]))

    for i in range(1, N+1):
        for k in range (B):
            ci=responses[i-1]+str(k)
            ri=puf(ci)
            if puf(ri)==H[i]:
                challenges.append(ci)
                responses.append(ri)
                break

    for j in range (L):
        xor_output = int(puf(responses[-1] + str(j)), 16) ^ int(Z[j], 2)
        S.append(bin(xor_output)[2:].zfill(n))

    return S

S_sol = sol_puz(c0, N, B, Z, helper_data)
print("#----------------------------------#")

for index, vector in enumerate(S_sol):
    print(f"S{index} (solved):", vector)

# for index, vector in enumerate(helper_data):
#     print(f"helper data{index} AFTER SOLVING:", vector)
    

def solution_equality(s1, s2):
    
    if len(s1) != len(s2):
        return False

    for v1, v2 in zip(s1, s2):
        if v1 != v2:
            return False

    return True

if solution_equality(S, S_sol):
    print("The solved solution is the same as locked solution.")
else:
    print("The solved solution is not the same as locked solution!!")