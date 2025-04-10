import random
from scipy.stats import norm
import math
import cma
import numpy as np

def create_objective_function(mu, sig, t, tc, e):
    def objective_function(params):
        h = params
        N = 4 * h**2 * t**2 / (3 * e**2)
        B = 3 * e**2 / (2 * h**2 * t * tc)

        # Converts to scalar (if necessary):
        if isinstance(N, np.ndarray) and N.size == 1:
            N = N.item()  
        if isinstance(B, np.ndarray) and B.size == 1:
            B = B.item()

        N_r=round(N)
        B_r=round(B)
        mu_r=(N_r*B_r)/2
        sig_r=(np.sqrt(N_r/12))*(B_r)*tc
        loss = abs((mu - (mu_r))mu) + abs((sig - (sig_r))/sig)
        return loss
    return objective_function

def opt(t, tc, e, p_min, B_min):
    # Optimization with CMA-ES
    h_min = -norm.ppf((1 - p_min) / 2)
    h=h_min  
    N = 4 * h**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * h**2 * t * tc)
    mu=(N*B)/2
    sig=(np.sqrt(N/12))*(B)*tc
    
    initial_params = [h]  # here is the starting value of h
    objective_function = create_objective_function(mu, sig, t, tc, e)
    options = {'bounds': [h_min, 20], 'seed': 1234}
    es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
    es.optimize(objective_function)
    h_tuned= es.result.xbest  # Best solution found
    best_value = es.result.fbest  # Objective value of the best solution

    p_real=1-2*(norm.cdf(-(h_tuned)))
    N = 4 * (h_tuned)**2 * t**2 / (3 * e**2)
    B = 3 * e**2 / (2 * (h_tuned)**2 * t * tc)
    sig_real=(np.sqrt(N/12))*(B)*tc
    mu=(N*B)/2
    #sig_real=e/(2*h_tuned)
    #N=(mu**2 * tc**2)/(3* sig_real**2)
    #B=(2* mu)/N
    e_verification=2*sig_real*h_tuned
    return h_tuned, N, B, p_real, sig_real, mu, best_value, e_verification
t=100
tc=0.000000000000000317
e=1/365
p=0.95
B=1024
h_tuned, N, B, p_real, sig_real, mu, best_value, e_verification=opt(t, tc, e, p, B)
h_min = -norm.ppf((1 - p) / 2)

n1=math.log2(N)
b1=math.log2(B)
print(" h_min: ", h_min)
print(" h_tuned: ", h_tuned)
print(" N:{N}= 2^", n1)
print(" B:{B}= 2^", b1)
print(" sig_real: ", sig_real)
print(" mu: ", mu)
print(f" p_real:{p_real}, best_value:{best_value}, e_verification:{e_verification} ")

# def evaluate_loss(a, b):
#     return abs((a - round(a))/a) + abs((b - round(b))/b)

# def objective_function(params):
#     a, b = params
#     return evaluate_loss(a, b)

# def opt(t, tc, e, p_min, B_min):
#     h_min = -norm.ppf((1 - p_min) / 2)
#     h_max=np.sqrt((3* e**2)/(2*B_min *t*tc))
#     mu=t/tc #mu is constant
#     sig_min=e/(2*h_max)
#     sig_max=e/(2*h_min)

#     upper_bound = max(sig_max, h_max, h_min, sig_min, 20)
#     lower_bound=min(h_min, sig_min, sig_max, h_max)
#     print("N_max: ", (2*mu)/B_min)
#     print("h_min: ", h_min)
#     print("h_max: ", h_max)
#     print("mu: ", mu)
#     print("sig_min: ", sig_min)
#     print("sig_max: ", sig_max)
#     print("lower_bound: ", lower_bound)
#     print("upper_bound: ", upper_bound)
#     h=h_min
#     sig=e/(2*h)
#     initial_params = [h, sig]  # Example initial guesses for N and B

#     options = {'bounds': [[h_min, lower_bound],[upper_bound, upper_bound]], 'seed': 1234}
#     es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
#     es.optimize(objective_function)
#     # Access the best solution after the optimization
#     h_tuned, s = es.result.xbest  # Best solution found
#     best_value = es.result.fbest  # Objective value of the best solution

#     print("h_tuned: ", h_tuned)
#     print("s: ", s)
    
#     p_real=1-2*(norm.cdf(-(h_tuned)))
#     #sig_real=s
#     sig_real=e/(2*h_tuned)
#     N=(mu**2 * tc**2)/(3* sig_real**2)
#     B=(2* mu)/N
#     ee=2*sig_real*h_tuned
#     return h_tuned, N, B, p_real, sig_real, best_value, ee

# Run the CMA-ES optimization
# t=100
# tc=0.000000000000000317
# e=0.09
# p=1/365
# B=1024
# h_tuned, N, B, p_real, sig_real, best_value, e_verification=opt(t, tc, e, p, B)

# print(" h_tuned: ", h_tuned)
# print(" N:{N}= 2^",math.log2(N))
# print(" B:{B}= 2^", math.log2(B))
# print(f" p_real:{p_real}, sig_real:{sig_real}, best_value:{best_value}, e_verification:{e_verification} ")





# def evaluate_loss(a, e):
    
#     b=e/(2*a)
#     return abs((a - round(a))/a) + abs((b - round(b))/b)


# def objective_function(params):
#     a, e = params
#     return evaluate_loss(a, e)

# def opt(t, tc, e, p_min, B_min):
#     h_min = -norm.ppf((1 - p_min) / 2)
#     h_max=np.sqrt((3* e**2)/(2*B_min *t*tc))
#     mu=t/tc
#     sig_min=e/(2*h_max)
#     sig_max=e/(2*h_min)

#     thr = max(sig_max, h_max)

#     print("h_min: ", h_min)
#     print("h_max: ", h_max)
#     print("mu: ", mu)
#     print("sig: ", sig_min)
#     sig=sig_min
#     h=h_min
#     initial_params = [h, e]  # Example initial guesses for N and B

#     options = {'bounds': [0, thr], 'seed': 1234}
#     es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
#     es.optimize(objective_function)
#     # Access the best solution after the optimization
#     h_tuned, s = es.result.xbest  # Best solution found
#     best_value = es.result.fbest  # Objective value of the best solution

#     print("h_tuned: ", h_tuned)
#     print("s: ", s)
    
#     p_real=1-2*(norm.cdf(-(h_tuned)))
#     sig_real=e/(2*h_tuned)
#     N=(mu**2 * tc**2)/(3* sig_real**2)
#     B=(2* mu)/N
#     ee=2*sig_real*h_tuned
#     return h_tuned, N, B, p_real, sig_real, best_value, ee

# # Run the CMA-ES optimization
# h_tuned, N, B, p_real, sig_real, best_value, ee=opt(100, 0.000000000000000317, 1, 0.99, 1000000000)

# print(f"results as h_tuned:{h_tuned}, N:{N}, B:{B}, p_real:{p_real}, sig_real:{sig_real}, best_value:{best_value}, ee:{ee} ")





# def evaluate_loss(a, b):
#     return abs((a - round(a))/a) + abs((b - round(b))/b)


# def objective_function(params):
#     N, B = params
#     return evaluate_loss(N, B)

# def opt(t, tc, e, p_min, B_min):
#     h_min = -norm.ppf((1 - p_min) / 2)
#     h_max=np.sqrt((3* e**2)/(2*B_min *t*tc))
#     mu=t/tc
#     sig_min=e/(2*h_max)
#     sig_max=e/(2*h_min)

#     if sig_max>h_max:
#         thr=sig_max
#     else:
#         thr=h_max

#     print("h_min: ", h_min)
#     print("h_max: ", h_max)
#     print("mu: ", mu)
#     print("sig: ", sig_min)
#     sig=sig_min
#     h=h_min
#     initial_params = [h, sig]  # Example initial guesses for N and B

#     options = {'bounds': [0, thr], 'seed': 1234}
#     es = cma.CMAEvolutionStrategy(initial_params, 0.5, options)
#     es.optimize(objective_function)
#     # Access the best solution after the optimization
#     h_tuned, sig_real = es.result.xbest  # Best solution found
#     best_value = es.result.fbest  # Objective value of the best solution

#     print("h_tuned: ", h_tuned)
#     print("sig_real: ", sig_real)
#     N=(mu**2 * tc**2)/(3* sig_real**2)
#     B=(2* mu)/N
#     #h_tuned=e/(2*sig_real)
#     p_real=1-2*(norm.cdf(-(h_tuned)))
#     ee=2*sig_real*h_tuned
#     return h_tuned, N, B, p_real, best_value, ee

# # Run the CMA-ES optimization
# h_tuned, N, B, p_real, best_value, ee=opt(100, 0.000000000000000317, 1, 0.99, 1000000000)

# print(f"results as h_tuned:{h_tuned}, N:{N}, B:{B}, p_real:{p_real}, best_value:{best_value}, ee:{ee} ")