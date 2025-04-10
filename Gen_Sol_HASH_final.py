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

import matplotlib.pyplot as plt

from scipy.stats import norm, shapiro

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
    objective_function = create_objective_function(t, tc, e)
    options = {'bounds': [h_min, h_max], 'seed': 1234}
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
     
####-----------Generate Puzzle: ------------------------------------------------------------------#
def gen_puz(N, B, L, lambda_, S):
    # Parameters based on lambda_ and h
    #N = lambda_ // 16  # Example function of lambda_ for N
    
    initial_seed = os.urandom(lambda_ // 8).hex()  # Random seed c0 generated inside the algorithm #16 bytes # the // 8 converts bits to bytes

    Z = []  # To store Z outputs
    helper_data = []  # To store helper data
    challenges=[]
    responses=[]
    challenges=[initial_seed]
    
    
    for i in range(1, N + 2):
        
        responses.append(puf(challenges[i-1]))
        helper_data.append(puf(responses[i-1]))       
        # Randomly select k from [0, B-1] and use it to generate the next seed
        k = random.randint(0, B-1)  # Generate k randomly within the specified range
        challenges.append(responses[i - 1] + str(k))  # Use the response at index k to generate the next seed

    for j in range(L):
        xor_output = int(puf(responses[-1] + str(j)), 16) ^ int(S[j], 2)
        Z.append(bin(xor_output)[2:].zfill(n))


    return initial_seed, Z, helper_data



## -----------------PUZZLE SOLVING: --------------------------------------------------------------#

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
t=60
#tc=0.0000019941329956054688 #seconds
#tc=0.000004681343203978919
tc=0.0000042812264110301671
evaluations=100
e=t*0.1
p=0.95
B_min=100
n = 256  # Number of bits in each vector
lambda_ = n  # Security parameter



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
h_min=-norm.ppf((1 - p) / 2)

print("#----------------------------------#")
print("h_min", h_min)
N1=4 * (h_min)**2 * t**2 / (3 * e**2)
B1=3 * e**2 / (2 * (h_min)**2 * t * tc)
t1=(N1*B1*tc)/2
print("N1: ", N1)
print("B1: ", B1)
print("NB1: ",N1*B1)
print("mu1=(NB1)/2: ", (N1*B1)/2)
print("t1:", t1)
print("e:", e)
st1=(np.sqrt(N1/12))*(B1)*tc
print("st1:", st1)
print("#----------------------------------#")
print("h_tuned: ", h )
print("N : ", N)
print("N2: ", N2)
print("B : ", B )
print("B2: ", B2)
print("NB2: ",N2*B2)
print("mu2=(NB2)/2: ",(N2*B2)/2)
t2=(N2*B2*tc)/2
print("t2:",t2)
print("e2:", 2*h*(np.sqrt(N2/12))*(B2)*tc )
print("Sigma: ", (np.sqrt(N2/12))*(B2)*tc)
print("NB1-NB2= ",N1*B1-N2*B2)
st2=(np.sqrt(N2/12))*(B2)*tc
print("st2:", st2)
print("#----------------------------------#")
# Generate each vector si and add to the solution set S
for i in range(L):
    # Generate a random n-bit number and convert to binary string, padded with zeros
    si = bin(random.getrandbits(n))[2:].zfill(n)
    S.append(si)

gen_duration=0
sol_duration=0
x=0
sol_t=[]
for k in range (evaluations):
    time1 = time.time()
    #GENERATE PUZZLE:
    c0, Z, helper_data = gen_puz(N2, B2, L, lambda_, S)
    time2 = time.time()
    gen_duration+=(time2-time1)
    #SOLVE PUZZLE:
    time3 = time.time()
    S_sol = sol_puz(c0, N2, B2, Z, helper_data)
    time4 = time.time()
    tt=time4-time3
    sol_t.append(tt)
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
print("sol_t:",sol_t)
# Plot histogram
solving_times=sol_t
# Plot histogram of solving times
plt.hist(solving_times, bins=10, alpha=0.6, color='g', density=True, label='Solving Times')

# Fit a normal distribution to the solving times
mu, std = norm.fit(solving_times)
xmin, xmax = plt.xlim()
x = np.linspace(xmin, xmax, 100)
p = norm.pdf(x, mu, std)
plt.plot(x, p, 'k', linewidth=2, label=f'Dist of Evaluations time: $\mu={mu:.2f}, \sigma={std:.2f}$')

# Plot the theoretical normal distribution
p_theoretical = norm.pdf(x, t, st1)
plt.plot(x, p_theoretical, 'r--', linewidth=2, label=f'Non-optimized model (using h_min): $\mu={t1}, \sigma={st1:.10f}$')
# tt=(N*B*tc)/2
p_theoretical2 = norm.pdf(x, t, st2)
plt.plot(x, p_theoretical2, 'b--', linewidth=2, label=f'Optimized model (using tuned h): $\mu={t2}, \sigma={st2:.10f}$')

# Adding labels and title
plt.title("Comparison of Solving Time Distribution")
plt.xlabel('Solving Time (seconds)')
plt.ylabel('Density')
plt.legend()

# Show the plot
plt.show()

# # Plot histogram of solving times
# plt.hist(solving_times, bins=10, alpha=0.6, color='g', density=True, label='Solving Times')

# # Fit a normal distribution to the solving times
# mu, std = norm.fit(solving_times)
# xmin, xmax = plt.xlim()
# xxx = np.linspace(xmin, xmax, 100)
# p = norm.pdf(x, mu, std)
# plt.plot(xxx, p, 'k', linewidth=2, label=f'Desired solving t: $\mu={mu:.2f}, \sigma={std:.2f}$')

# # Plot the theoretical normal distribution
# p_theoretical = norm.pdf(xxx, t, st1)
# plt.plot(xxx, p_theoretical, 'r--', linewidth=2, label=f'Theoretical Normal: $\mu={t}, \sigma={st1:.10f}$')

# # Adding labels and title
# plt.title("Comparison of Solving Time Distribution")
# plt.xlabel('Solving Time (seconds)')
# plt.ylabel('Density')
# plt.legend()

# # Show the plot
# plt.show()


# Perform Shapiro-Wilk test for normality
stat, p_value = shapiro(solving_times)
print('Statistics=%.3f, p=%.3f' % (stat, p_value))

# Interpret
alpha = 0.05
if p_value > alpha:
    print('Sample looks Gaussian (fail to reject H0)')
else:
    print('Sample does not look Gaussian (reject H0)')
