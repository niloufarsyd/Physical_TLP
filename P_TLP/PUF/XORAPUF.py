import numpy as np
from typing import Union, Callable
from .base import Simulation
from .delay import SimulationMajorityLTFArray


class XORArbiterPUF(Simulation):
    def __init__(self, n: int, k: int, weight_array: np.ndarray, transform: Union[Callable, str], combiner: Union[Callable, str], sigma_noise: float, seed: int, vote_count: int = 1, bias: np.ndarray = None):
        """
        Initialize the XOR Arbiter PUF.
        
        :param n: Number of stages.
        :param k: Number of Arbiter PUFs.
        :param weight_array: Array of weights representing the PUF stage delays.
        :param transform: Function to transform input challenges.
        :param combiner: Function to combine the outputs of k PUFs to one bit result.
        :param sigma_noise: Standard deviation of noise distribution.
        :param seed: Seed for pseudo-random number generator to generate noise.
        :param vote_count: Number of votes for majority voting.
        :param bias: Bias for the PUF responses.
        """
        #print("[DEBUG] Using CUSTOM XORArbiterPUF — sigma_noise =", sigma_noise)
        self.n = n
        self.k = k
        self.simulation = SimulationMajorityLTFArray(weight_array, transform, combiner, sigma_noise, seed, vote_count, bias)

    @property
    def challenge_length(self) -> int:
        return self.n

    @property
    def response_length(self) -> int:
        return 1

    def eval(self, challenges: np.ndarray) -> np.ndarray:
        """
        Evaluate the XOR Arbiter PUF on a list of given challenges.
        
        :param challenges: List of challenges to evaluate on. Shape should be (N, n), where N is the number of challenges.
        :return: Array of responses, shape (N, 1).
        """
        raw_responses = self.simulation.eval(challenges)
        return (raw_responses + 1) // 2  # Convert -1 to 0 and 1 to 1

    def r_eval(self, r: int, challenges: np.ndarray) -> np.ndarray:
        """
        Evaluate the XOR Arbiter PUF multiple times on a list of given challenges.
        
        :param r: Number of evaluations.
        :param challenges: List of challenges to evaluate on. Shape should be (N, n), where N is the number of challenges.
        :return: Array of responses, shape (r, N, 1).
        """
        raw_responses = self.simulation.r_eval(r, challenges)
        return (raw_responses + 1) // 2  # Convert -1 to 0 and 1 to 1

# # Example usage:
# # Define the parameters for the XOR Arbiter PUF
# n = 64  # Number of stages
# k = 4   # Number of Arbiter PUFs
# weight_array = np.random.randn(k, n)  # Random weights

# # Updated transform function to accept two arguments
# transform = lambda x, k: np.broadcast_to(x, (k,) + x.shape).transpose(1, 0, 2) 

# # Updated combiner function to handle the input properly
# combiner = lambda x: np.prod(x, axis=1)

# sigma_noise = 0.01
# seed = 42
# vote_count = 1
# bias = None

# # Create an instance of XOR Arbiter PUF
# xor_arbiter_puf = XORArbiterPUF(n, k, weight_array, transform, combiner, sigma_noise, seed, vote_count, bias)

# # Generate a random challenge
# challenge = np.random.randint(0, 2, (1, n))

# # Get the response for the challenge
# response = xor_arbiter_puf.eval(challenge)
# print("Response:", response)
