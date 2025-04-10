import random
from scipy.stats import norm
import math
import cma
import numpy as np

def evaluate_loss(N, B):
    return abs(N - round(N)) + abs(B - round(B))

# def generate_parameters1():
#     p = 0.999
#     h = -norm.ppf((1 - p) / 2)
#     t = random.uniform(1, 100)
#     tau = random.uniform(10**(-17), 10**(-16))
#     e = random.uniform(t/36500, t/18250)

#     N = 4 * h**2 * t**2 / (3 * e**2)
#     B = 3 * e**2 / (2 * h**2 * t * tau)
#     return N, B, t , tau, e, p

def generate_parameters(t, tau, p, e):   
    h = -norm.ppf((1 - p) / 2)
    N = 4 * h**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * h**2 * t * tau)
    return N, B

def objective_function(params):
    N, B = params
    return evaluate_loss(N, B)

def run_cma_es(N, B, e, t, tc, p_min):
    initial_params = [N, B]  # Example initial guesses for N and B
    B_min=1024
    
    mu=t/tc
    N_max=(2*mu)/B_min
    h_min = -norm.ppf((1 - p_min) / 2)
    B_max=3 * e**2 / (2 * h_min**2 * t * tc)
    N_min = 4 * (h_min)**2 * t**2 / (3 * e**2)
    
    print("N_min: ", N_min,"=2^", math.log2(N_min))
    print("N_max: ", N_max,"=2^", math.log2(N_max))
    print("B_min: ", B_min,"=2^", math.log2(B_min))
    print("B_max: ", B_max,"=2^", math.log2(B_max))
    print("h_min: ", h_min)

    options = {'bounds': [[2, B_min],[2*mu,B_max]], 'seed': 1}
    es = cma.CMAEvolutionStrategy(initial_params, 0.25, options)
    es.optimize(objective_function)
    # Access the best solution after the optimization
    BestN, BestB = es.result.xbest  # Best solution found
    best_value = es.result.fbest  # Objective value of the best solution
    return BestN, BestB, best_value

# Run the CMA-ES optimization
t=1000      #unlocking time
tc=0.000000000000000317
e=1/365     #error in t
p=0.99999   #probability of successfuly unlocking by solver
p_min=0.95  #minimum acceptable p
mu=t/tc
#[N, B, t , tc, e, p]=generate_parameters1()
[N, B]=generate_parameters(t, tc, p, e)
BestN, BestB, best_value = run_cma_es(N, B, e, t, tc, p_min)
h_tuned=np.sqrt((3* e**2)/(2*BestB *t*tc))

print("===============================")
print(f"Initia N is: N= {N}= 2^ {math.log2(N)}")
print(f"Initia B is: B= {B}= 2^ {math.log2(B)}")
print("===============================")
print("Best objective value: ", best_value)
print(f"N*B : {BestN*BestB}= 2^ {math.log2(BestN*BestB)}")
print(f"Best N is: N= {BestN}= 2^ {math.log2(BestN)}" )
print(f"Best B is: B= {BestB}= 2^ {math.log2(BestB)}" )
print("h_tuned: ",h_tuned)

