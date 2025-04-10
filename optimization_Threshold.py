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

if R_puf < 0.9:
    print("\nUsing Normal Approximation:")
    T_optimal, failure_prob = compute_T_opt_normal(lambda_, R_puf)
    print(f"T_optimal: {T_optimal:.3f}, Failure Probability: {failure_prob:.3e}")
    plot_hd_distributions_normal(lambda_, R_puf, T_optimal)
    plot_failure_probability_normal(lambda_, R_puf, T_optimal)
else:
    print("\nUsing Binomial Distribution:")
    T_optimal_binomial, failure_prob_binomial = compute_T_opt_binomial(lambda_, R_puf)
    print(f"T_optimal_binomial: {T_optimal_binomial:.3f}, Failure Probability: {failure_prob_binomial:.3e}")
    plot_hd_distributions_binomial(lambda_, R_puf, T_optimal_binomial)
    plot_failure_probability_binomial(lambda_, R_puf, T_optimal_binomial)


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

# Example Usage
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

# Plot the function with the corrected LaTeX formatting
plot_T_opt_vs_R()


# ###part 1:
# # Define function to compute corrected T_threshold
# ###==========================for R<0.9
# def compute_corrected_T_threshold(lambda_, R):
#     """
#     Computes the optimal T_threshold by minimizing the failure probability using cumulative density functions (CDFs),
#     ensuring that misclassification is minimized.

#     Parameters:
#     - lambda_: Length of the challenge-response (security parameter).
#     - R: PUF reliability (probability of correct response).

#     Returns:
#     - Corrected optimal T_threshold.
#     - Failure probability at T_optimal.
#     """
#     # Define mean and standard deviation for both distributions
#     mu_puf = lambda_ * (1 - R)
#     sigma_puf = np.sqrt(lambda_ * R * (1 - R))
#     mu_random = lambda_ / 2
#     sigma_random = np.sqrt(lambda_ / 4)

#     # Define normal CDFs (Cumulative Distribution Functions)
#     def puf_cdf(x):
#         return stats.norm.cdf(x, mu_puf, sigma_puf)

#     def random_cdf(x):
#         return stats.norm.cdf(x, mu_random, sigma_random)

#     # Define x range for threshold search
#     x_values = np.linspace(0, lambda_, 1000)

#     # Compute classification error: difference in cumulative probabilities
#     failure_prob_values = np.abs(random_cdf(x_values) - (1 - puf_cdf(x_values)))

#     # Find T_optimal where classification error is minimized
#     optimal_index = np.argmin(failure_prob_values)
#     T_optimal = x_values[optimal_index] / lambda_

#     # Compute failure probability at the optimal threshold
#     failure_prob_at_T = failure_prob_values[optimal_index]

#     return T_optimal, failure_prob_at_T



# # Define parameters
# lambda_ = 128  # Security parameter (response length)
# R_puf = 0.90  # PUF reliability

# # Compute corrected optimal T_threshold
# T_optimal, failure_prob = compute_corrected_T_threshold(lambda_, R_puf)

# # Display corrected results
# T_optimal, failure_prob

# print("T_optimal:", T_optimal)
# print("failure_prob:", failure_prob)

# # Plot the overlap of the two distributions and the optimal threshold

# # Define x-axis range
# x = np.linspace(0, lambda_, 1000)

# # Compute normal PDFs
# puf_hd_pdf = stats.norm.pdf(x, lambda_ * (1 - R_puf), np.sqrt(lambda_ * R_puf * (1 - R_puf)))
# random_hd_pdf = stats.norm.pdf(x, lambda_ / 2, np.sqrt(lambda_ / 4))

# # Compute intersection point for T_optimal
# T_optimal_value = T_optimal * lambda_

# # Plot distributions
# plt.figure(figsize=(8, 5))
# plt.plot(x, puf_hd_pdf, label="PUF HD Distribution (Normal Approx.)", color='blue')
# plt.plot(x, random_hd_pdf, label="Random HD Distribution (Normal Approx.)", color='red', linestyle='dashed')

# # Highlight the overlap region
# plt.fill_between(x, np.minimum(puf_hd_pdf, random_hd_pdf), color='purple', alpha=0.4, label="Overlap Region (Failure Probability)")

# # Mark the optimal T_threshold
# plt.axvline(x=T_optimal_value, color='green', linestyle='dotted', label=f"Optimal T_threshold = {T_optimal:.3f}")

# # Labels and legend
# plt.xlabel("Hamming Distance (HD)")
# plt.ylabel("Probability Density")
# plt.title("Failure Probability Region and Optimal Threshold Selection")
# plt.legend()
# plt.grid()
# plt.show()

# def plot_failure_probability_binomial(lambda_, R):
#     """
#     Plots the failure probability curve using the Binomial CDF for different threshold values.
    
#     Parameters:
#     - lambda_: Length of the challenge-response (security parameter).
#     - R: PUF reliability.
#     """
#     # Define binomial CDFs (vectorized for array inputs)
#     def puf_cdf(x):
#         return binom.cdf(np.floor(x).astype(int), lambda_, 1 - R)  # CDF for PUF response

#     def random_cdf(x):
#         return binom.cdf(np.floor(x).astype(int), lambda_, 0.5)  # CDF for random response

#     # Define x range for threshold search
#     x_values = np.linspace(0, lambda_, 1000)

#     # Compute classification error: difference in binomial cumulative probabilities
#     puf_cdf_values = puf_cdf(x_values)
#     random_cdf_values = random_cdf(x_values)
#     failure_prob_values = np.abs(random_cdf_values - (1 - puf_cdf_values))

#     # Find T_optimal where failure probability is minimized
#     optimal_index = np.argmin(failure_prob_values)
#     T_optimal = x_values[optimal_index] / lambda_

#     # Plot failure probability curve
#     plt.figure(figsize=(8, 5))
#     plt.plot(x_values / lambda_, failure_prob_values, label="Failure Probability", color='blue')
    
#     # Mark optimal threshold
#     plt.axvline(T_optimal, color='green', linestyle='dashed', label=f"Optimal T_threshold = {T_optimal:.3f}")
    
#     # Labels and legend
#     plt.xlabel("Threshold \( T / \lambda \)")
#     plt.ylabel("Failure Probability")
#     plt.title("Failure Probability vs. Threshold Using Binomial CDF")
#     plt.legend()
#     plt.grid()
#     plt.show()
# ###part 2:
# ###==========================for R>0.9
# def compute_corrected_T_threshold_binomial(lambda_, R):
#     """
#     Computes the optimal T_threshold by minimizing the failure probability using the Binomial CDF,
#     ensuring that misclassification is minimized.

#     Parameters:
#     - lambda_: Length of the challenge-response (security parameter).
#     - R: PUF reliability (probability of correct response).

#     Returns:
#     - Corrected optimal T_threshold based on Binomial distribution.
#     - Failure probability at T_optimal.
#     """
#     # Define binomial CDFs (vectorized for array inputs)
#     def puf_cdf(x):
#         return binom.cdf(np.floor(x).astype(int), lambda_, 1 - R)  # CDF for PUF response

#     def random_cdf(x):
#         return binom.cdf(np.floor(x).astype(int), lambda_, 0.5)  # CDF for random response

#     # Define x range for threshold search
#     x_values = np.linspace(0, lambda_, 1000)

#     # Compute classification error: difference in binomial cumulative probabilities
#     puf_cdf_values = puf_cdf(x_values)
#     random_cdf_values = random_cdf(x_values)
#     failure_prob_values = np.abs(random_cdf_values - (1 - puf_cdf_values))

#     # Find T_optimal where failure probability is minimized
#     optimal_index = np.argmin(failure_prob_values)
#     T_optimal = x_values[optimal_index] / lambda_

#     # Compute failure probability at the optimal threshold
#     failure_prob_at_T = failure_prob_values[optimal_index]

#     return T_optimal, failure_prob_at_T
# # Define parameters
# lambda_ = 128  # Security parameter (response length)
# R_puf = 0.97  # High PUF reliability

# # Compute optimal T_threshold using binomial CDF instead of normal CDF
# T_optimal_binomial, failure_prob_binomial = compute_corrected_T_threshold_binomial(lambda_, R_puf)

# # Display results
# T_optimal_binomial, failure_prob_binomial
# print("T_optimal_binomial: ",T_optimal_binomial)
# print("failure_prob_binomial: ", failure_prob_binomial)
# ###==========================
# # Plot the failure probability curve using the Binomial CDF
# R_puf_high=0.97
# plot_failure_probability_binomial(lambda_, R_puf_high)

# def plot_hd_distributions_binomial(lambda_, R, T_optimal):
#     """
#     Plots the Hamming Distance (HD) distributions for PUF and random responses using Binomial distributions.
#     Also marks the optimal threshold T_optimal.

#     Parameters:
#     - lambda_: Length of the challenge-response (security parameter).
#     - R: PUF reliability.
#     - T_optimal: Optimal threshold value.
#     """
#     # Define x-axis range (Hamming Distance values)
#     x_values = np.arange(0, lambda_ + 1)

#     # Compute Binomial PMFs
#     puf_hd_pmf = binom.pmf(x_values, lambda_, 1 - R)  # PMF for PUF response
#     random_hd_pmf = binom.pmf(x_values, lambda_, 0.5)  # PMF for random response

#     # Plot PMFs for PUF and random distributions
#     plt.figure(figsize=(8, 5))
#     plt.bar(x_values, puf_hd_pmf, width=1.0, alpha=0.6, label="PUF HD Distribution (Binomial)", color='blue')
#     plt.bar(x_values, random_hd_pmf, width=1.0, alpha=0.6, label="Random HD Distribution (Binomial)", color='red')

#     # Mark the optimal T_threshold
#     T_hd_value = int(T_optimal * lambda_)
#     plt.axvline(x=T_hd_value, color='green', linestyle='dashed', label=f"Optimal T_threshold = {T_hd_value}")

#     # Labels and legend
#     plt.xlabel("Hamming Distance (HD)")
#     plt.ylabel("Probability Mass Function (PMF)")
#     plt.title("Hamming Distance Distributions for PUF and Random Responses (Binomial)")
#     plt.legend()
#     plt.grid()
#     plt.show()

# # Plot HD distributions using the Binomial PMF and show the optimal T_threshold
# R_puf_high=0.97
# plot_hd_distributions_binomial(lambda_, R_puf_high, T_optimal_binomial)
