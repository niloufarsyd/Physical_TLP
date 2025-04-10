import numpy as np
from typing import Union, Callable
from PUF.base import Simulation
from PUF.delay import SimulationMajorityLTFArray


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
#-----------------------------------------------------------------------------------------------------#
# Function to evaluate PUF with a single challenge
# def PUF(puf_parameter):
#     xor_arbiter_puf = XORArbiterPUF(
#         puf_parameter['n'],
#         puf_parameter['k'],
#         puf_parameter['weight_array'],
#         puf_parameter['transform'],
#         puf_parameter['combiner'],
#         puf_parameter['sigma_noise'],
#         puf_parameter['seed'],
#         puf_parameter['vote_count'],
#         puf_parameter['bias']
#     )
#     response = xor_arbiter_puf.eval(puf_parameter['challenge'])
#     return response


# Function to evaluate PUF with a single challenge


# Function to expand an n-bit challenge to a (64*n)-bit challenge using a PRNG
def expand_challenge(seed_challenge: np.ndarray, n: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    print("n:", n)
    expanded_bits  = rng.integers(0, 2, (n * 64,))
    seed_challenge_flat = np.tile(seed_challenge, 64).flatten()[:n * 64]

    # XOR the seed_challenge with the expanded_bits
    expanded_challenge = np.bitwise_xor(expanded_bits, seed_challenge_flat)

#    j=n//64
    print("expanded_bits :",expanded_bits)
    print("seed_challenge_flat :",seed_challenge_flat)
    print("expanded_challenge :",expanded_challenge)

    # for i in range (j):
    #     x = np.bitwise_xor(expanded_challenge[64*i:64*i+63], seed_challenge)
    #     expanded_challenge[64*i:64*i+63]=x

      
    return expanded_challenge

# Function to generate n-bit responses from an n-bit challenge
def XOR_PUF(puf_parameter, chal):
    seed_challenge = chal
    n = len(seed_challenge[0])
    seed = puf_parameter['seed']
    print("len(seed_challenge):",n)
    # Generate a (64*n)-bit expanded challenge vector
    expanded_challenge = expand_challenge(seed_challenge, n, seed)
    print("seed_challenge:",seed_challenge)
    print("expanded_challenge:",expanded_challenge)
    # Split the expanded challenge into n segments of 64 bits each
    challenge_segments = np.split(expanded_challenge, n)
    print("challenge_segments:",challenge_segments)
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
    
    # Evaluate each segment and collect the responses
    for i, segment in enumerate(challenge_segments):
        response = xor_arbiter_puf.eval(segment.reshape(1, -1))
        responses[i] = response
    
    return responses, expanded_challenge

# Example usage
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

chal_length=256
chal=np.random.randint(0, 2, chal_length),  # n-bit challenge (e.g., n=256)
# Get n-bit response from n-bit challenge
responses, expand_challenges = XOR_PUF(puf_parameter, chal)
print("chal:",chal)
print("challenge: ",expand_challenges)
print("n-bit Response:", responses)