import random
from scipy.stats import norm
import math
import cma
import numpy as np
import matplotlib. pyplot as plt
import scipy.integrate as integrate
import scipy.stats as stats
from scipy.stats import binom


### ========================= Part 1: Normal Approximation for R < 0.9 =========================
def compute_T_opt_normal(lambda_, R):
    """
    Computes the optimal T_threshold by minimizing failure probability using Normal CDF.
    This method is valid for R < 0.9.

    Parameters:
    - lambda_: Security parameter (length of response).
    - R: PUF reliability.

    Returns:
    - Optimal T_threshold.
    - Failure probability at T_optimal.
    """
    # Define mean and standard deviation for both distributions
    mu_puf, sigma_puf = lambda_ * (1 - R), np.sqrt(lambda_ * R * (1 - R))
    mu_random, sigma_random = lambda_ / 2, np.sqrt(lambda_ / 4)

    # Define normal CDFs
    def puf_cdf(x): return norm.cdf(x, mu_puf, sigma_puf)
    def random_cdf(x): return norm.cdf(x, mu_random, sigma_random)

    # Define x range for threshold search
    x_values = np.linspace(0, lambda_, 1000)

    # Compute classification error and find optimal T
    failure_prob_values = np.abs(random_cdf(x_values) - (1 - puf_cdf(x_values)))
    optimal_index = np.argmin(failure_prob_values)
    T_optimal = x_values[optimal_index] / lambda_
    failure_prob_at_T = failure_prob_values[optimal_index]

    return T_optimal, failure_prob_at_T

def plot_hd_distributions_normal(lambda_, R, T_optimal):
    """Plots Hamming Distance distributions using Normal Approximation."""
    x = np.linspace(0, lambda_, 1000)
    puf_hd_pdf = norm.pdf(x, lambda_ * (1 - R), np.sqrt(lambda_ * R * (1 - R)))
    random_hd_pdf = norm.pdf(x, lambda_ / 2, np.sqrt(lambda_ / 4))

    plt.figure(figsize=(8, 5))
    plt.plot(x, puf_hd_pdf, label="PUF HD Distribution (Normal Approx.)", color='blue')
    plt.plot(x, random_hd_pdf, label="Random HD Distribution (Normal Approx.)", color='red', linestyle='dashed')
    plt.axvline(x=T_optimal * lambda_, color='green', linestyle='dotted', label=f"Optimal T_threshold = {T_optimal:.3f}")
    plt.xlabel("Hamming Distance (HD)")
    plt.ylabel("Probability Density")
    plt.title("Hamming Distance Distributions (Normal Approx.)")
    plt.legend()
    plt.grid()
    plt.show()

def plot_failure_probability_normal(lambda_, R, T_optimal):
    """Plots Failure Probability vs. Threshold using Normal Approximation."""
    mu_puf, sigma_puf = lambda_ * (1 - R), np.sqrt(lambda_ * R * (1 - R))
    mu_random, sigma_random = lambda_ / 2, np.sqrt(lambda_ / 4)

    def puf_cdf(x): return norm.cdf(x, mu_puf, sigma_puf)
    def random_cdf(x): return norm.cdf(x, mu_random, sigma_random)

    x_values = np.linspace(0, lambda_, 1000)
    failure_prob_values = np.abs(random_cdf(x_values) - (1 - puf_cdf(x_values)))

    plt.figure(figsize=(8, 5))
    plt.plot(x_values / lambda_, failure_prob_values, label="Failure Probability (Normal)", color='blue')
    plt.axvline(T_optimal, color='green', linestyle='dashed', label=f"Optimal T_threshold = {T_optimal:.3f}")
    plt.xlabel("Threshold \( T / \lambda \)")
    plt.ylabel("Failure Probability")
    plt.title("Failure Probability vs. Threshold Using Normal Approximation")
    plt.legend()
    plt.grid()
    plt.show()

### ========================= Part 2: Binomial Distribution for R >= 0.9 =========================
def compute_T_opt_binomial(lambda_, R):
    """
    Computes the optimal T_threshold by minimizing the failure probability using the Binomial CDF.
    This method is valid for R >= 0.9.

    Parameters:
    - lambda_: Security parameter (length of response).
    - R: PUF reliability.

    Returns:
    - Optimal T_threshold based on Binomial distribution.
    - Failure probability at T_optimal.
    """
    # Define binomial CDFs
    def puf_cdf(x): return binom.cdf(np.floor(x).astype(int), lambda_, 1 - R)
    def random_cdf(x): return binom.cdf(np.floor(x).astype(int), lambda_, 0.5)

    # Define x range for threshold search
    x_values = np.linspace(0, lambda_, 1000)

    # Compute classification error and find optimal T
    failure_prob_values = np.abs(random_cdf(x_values) - (1 - puf_cdf(x_values)))
    optimal_index = np.argmin(failure_prob_values)
    T_optimal = x_values[optimal_index] / lambda_
    failure_prob_at_T = failure_prob_values[optimal_index]

    return T_optimal, failure_prob_at_T

def plot_hd_distributions_binomial(lambda_, R, T_optimal):
    """Plots Hamming Distance distributions using the Binomial Distribution."""
    x_values = np.arange(0, lambda_ + 1)
    puf_hd_pmf = binom.pmf(x_values, lambda_, 1 - R)
    random_hd_pmf = binom.pmf(x_values, lambda_, 0.5)

    plt.figure(figsize=(8, 5))
    plt.bar(x_values, puf_hd_pmf, width=1.0, alpha=0.6, label="PUF HD Distribution (Binomial)", color='blue')
    plt.bar(x_values, random_hd_pmf, width=1.0, alpha=0.6, label="Random HD Distribution (Binomial)", color='red')
    plt.axvline(x=int(T_optimal * lambda_), color='green', linestyle='dashed', label=f"Optimal T_threshold = {int(T_optimal * lambda_)}")
    plt.xlabel("Hamming Distance (HD)")
    plt.ylabel("Probability Mass Function (PMF)")
    plt.title("Hamming Distance Distributions (Binomial)")
    plt.legend()
    plt.grid()
    plt.show()

def plot_failure_probability_binomial(lambda_, R, T_optimal):
    """Plots Failure Probability vs. Threshold using Binomial Distribution."""
    def puf_cdf(x): return binom.cdf(np.floor(x).astype(int), lambda_, 1 - R)
    def random_cdf(x): return binom.cdf(np.floor(x).astype(int), lambda_, 0.5)

    x_values = np.linspace(0, lambda_, 1000)
    failure_prob_values = np.abs(random_cdf(x_values) - (1 - puf_cdf(x_values)))

    plt.figure(figsize=(8, 5))
    plt.plot(x_values / lambda_, failure_prob_values, label="Failure Probability (Binomial)", color='blue')
    plt.axvline(T_optimal, color='green', linestyle='dashed', label=f"Optimal T_threshold = {T_optimal:.3f}")
    plt.xlabel("Threshold \( T / \lambda \)")
    plt.ylabel("Failure Probability")
    plt.title("Failure Probability vs. Threshold Using Binomial CDF")
    plt.legend()
    plt.grid()
    plt.show()

### ========================= Running the Computation Based on R =========================
# Define parameters
lambda_ = 256  # Security parameter (response length)
R_puf = 0.9 # Example PUF reliability

# if R_puf < 0.9:
#     print("\nUsing Normal Approximation:")
#     T_optimal, failure_prob = compute_T_opt_normal(lambda_, R_puf)
#     print(f"T_optimal: {T_optimal:.3f}, Failure Probability: {failure_prob:.3e}")
#     plot_hd_distributions_normal(lambda_, R_puf, T_optimal)
#     plot_failure_probability_normal(lambda_, R_puf, T_optimal)
# else:
#     print("\nUsing Binomial Distribution:")
#     T_optimal_binomial, failure_prob_binomial = compute_T_opt_binomial(lambda_, R_puf)
#     print(f"T_optimal_binomial: {T_optimal_binomial:.3f}, Failure Probability: {failure_prob_binomial:.3e}")
#     plot_hd_distributions_binomial(lambda_, R_puf, T_optimal_binomial)
#     plot_failure_probability_binomial(lambda_, R_puf, T_optimal_binomial)


###-------------The T_opt vs Reliability plot
def compute_T_opt_formula(R):
    """
    Computes the optimal T_threshold using the exact formula derived from Binomial PMFs.

    Parameters:
    - R: PUF reliability.

    Returns:
    - Optimal T_threshold value.
    """
    return (np.log(0.5) - np.log(R)) / (np.log(1 - R) - np.log(R))


R_puf = 0.97  # High PUF reliability
T_opt_formula = compute_T_opt_formula(R_puf)

# Display result
T_opt_formula
def plot_T_opt_vs_R():
    """
    Plots the relationship between T_optimal and R using the derived formula,
    ensuring proper LaTeX formatting in Matplotlib.
    """
    # Define range of R values
    R_values = np.linspace(0.51, 0.99, 200)  # Avoid R = 0.5 and 1 to prevent division issues

    # Compute T_opt for each R
    T_opt_values = [compute_T_opt_formula(R) for R in R_values]

    # Plot the results
    plt.figure(figsize=(8, 5))
    plt.plot(R_values, T_opt_values, label=r"$T_{\mathrm{opt}}$ from formula", color='blue')
    
    # Highlight the specific value for R = 0.97
    R_puf = 0.9  # Example PUF reliability
    T_opt_formula = compute_T_opt_formula(R_puf)
    plt.scatter(R_puf, T_opt_formula, color='red', label=f"$R = {R_puf}$, $T_{{\mathrm{{opt}}}} = {T_opt_formula:.3f}$", zorder=3)

    # Labels and title (corrected LaTeX formatting)
    plt.xlabel("PUF Reliability (R)")
    plt.ylabel(r"Optimal Threshold $T_{\mathrm{opt}}$")
    plt.title(r"Optimal $T_{\mathrm{opt}}$ vs. PUF Reliability ($R$)")
    plt.legend()
    plt.grid()

    # Show the plot
    plt.show()

### ========update:===========================================================:
### B is now included in P_failure formula 
### ========================= the T_opt Computation Based on B and R =========
# Plot the function with the corrected LaTeX formatting
#plot_T_opt_vs_R()
def failure_prob_b(T, lambda_, B, R):
    from scipy.stats import binom

    T_scaled = int(T * lambda_)
    cdf_random = binom.cdf(T_scaled, lambda_, 0.5)
    cdf_puf = binom.cdf(T_scaled, lambda_, 1 - R)
    
    false_positive = 1 - (1 - cdf_random)**B
    false_negative = 1 - cdf_puf
    
    return false_positive + false_negative

from scipy.optimize import minimize_scalar
res = minimize_scalar(lambda T: failure_prob_b(T, lambda_=128, B=189000, R=0.97), bounds=(0, 1), method='bounded')
T_opt_B = res.x
print("T_opt_B: ", T_opt_B)

def find_strict_T_opt(lambda_, B, R, alpha=1e-10):
    """
    Compute T_opt strictly to avoid false positives.
    
    Parameters:
        lambda_ (int): Security parameter (length of response)
        B (int): Branching factor (number of candidates)
        alpha (float): Desired max FP probability (very small)
    
    Returns:
        float: optimal threshold T_opt
    """
    #Percentage Point Function (PPF)
    quantile = alpha / B
    T_threshold1 = binom.ppf(quantile, lambda_, 0.5) / lambda_
    T_threshold2 = binom.ppf(1-quantile, lambda_, 1-R) / lambda_
    return T_threshold1, T_threshold2
###========d(P_failure)/dT=0=> T_opt=?===================================================
###--- find optimal Threshold by making derivation of P_failure equal to zero and find the root--
# Example usage
lambda_ = 128
B = 2000
R=0.97
T_opt1, T_opt2 = find_strict_T_opt(lambda_, B,R)
# print(f"T_opt1 (strict FP avoidance) = {T_opt1:.4f}")
# print(f"T_opt2 (strict FP avoidance) = {T_opt2:.4f}")

from scipy.optimize import bisect

def f_random(x):
    return binom.pmf(int(x), lambda_, 0.5)

def F_random(x):
    return binom.cdf(int(x), lambda_, 0.5)

def f_puf(x):
    return binom.pmf(int(x), lambda_, 1-R)

def F_puf(x):
    return binom.cdf(int(x), lambda_, 1-R)

def optimal_condition(T_lambda):
    left_side = B * ((1 - F_random(T_lambda))**(B - 1)) * f_random(T_lambda)
    right_side = f_puf(T_lambda)
    return left_side - right_side

T_vals = np.linspace(0.0, 0.5, 1000)
T_lambda_vals = T_vals * lambda_

# Compute values of optimal_condition for each T·λ
slope_vals = [optimal_condition(tl) for tl in T_lambda_vals]

plt.figure(figsize=(10, 6))
plt.plot(T_vals, slope_vals, label=r"$\frac{dP_{failure}}{dT\cdot\lambda}$", color="purple")
plt.axhline(0, color="gray", linestyle="--")
plt.xlabel("Threshold T")
plt.ylabel("d(P_failure) / d(T·λ)")
plt.title("Derivative of Failure Probability vs Threshold")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
# for T, slope in zip(T_vals, slope_vals):
#     print(f"T = {T:.5f}, dP_failure/dTλ = {slope:.5e}")

for i in range(1, len(slope_vals)):
    if slope_vals[i-1] < 0 and slope_vals[i] > 0:
        T_opt_estimated = T_vals[i]
        break
else:
    T_opt_estimated = None  # No crossing found
##These values seems ok now:
print("T_opt estimated from derivation:", T_opt_estimated)
T_lambda = 0.3 * lambda_
f_r = F_random(T_lambda)
f_p = F_puf(T_lambda)
FP = 1 - (1 - f_r)**B
FN = 1 - f_p
P_fail =  min(0.1, FP + FN)
print("P failure for this T_opt:", P_fail)

###=====Numerically:============================================================
###=== for T in range: P_fail(T)=... min(P_fail)=> T_opt 
###Numerically find the opt Threshold value that gives the lowest P_failure:
# R = 0.97
# B = 10000

# Threshold range:
T_values = np.linspace(0.0, 0.5, 10000)

P_failure = []
F_random_vals = []
F_puf_vals = []
FP_vals = []
FN_vals = []
for T in T_values:
    T_lambda = T * lambda_
    f_r = F_random(T_lambda)
    f_p = F_puf(T_lambda)
    FP = 1 - (1 - f_r)**B
    FN = 1 - f_p
    P_fail = min(1.0, FP + FN)

    # Save
    P_failure.append(P_fail)
    F_random_vals.append(f_r)
    F_puf_vals.append(f_p)
    FP_vals.append(FP)
    FN_vals.append(FN)

# Plot all
plt.figure(figsize=(10, 6))
plt.plot(T_values, P_failure, label="P_failure", linewidth=2)
plt.plot(T_values, F_random_vals, label="F_random", linestyle='--')
plt.plot(T_values, F_puf_vals, label="F_puf", linestyle='-.')
plt.plot(T_values, FP_vals, label="FP", linestyle=':')
plt.plot(T_values, FN_vals, label="FN", linestyle='solid')
plt.xlabel("T (Threshold)")
plt.ylabel("Probability")
plt.title("P_failure, F_random, and F_puf vs. Threshold T for R=0.97 and B=1000")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()