import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm, shapiro
import os


# # Example solving times data
# solving_times = [58.48396587371826, 58.05940294265747, 58.794896364212036, 57.21922707557678, 63.027870416641235, 69.66175627708435, 60.02699947357178, 56.57687067985535, 58.20390319824219, 57.62353181838989, 59.683313846588135, 55.87482237815857, 57.053484201431274, 57.460585832595825, 56.161232709884644, 57.92823362350464, 55.99131751060486, 57.777132987976074, 58.75634765625, 57.57689452171326]

# # Parameters for the theoretical normal distribution
# t = 60  # Mean
# st1 = 1.530640370773962  # Standard deviation (example value)
# st2 = 1.0981861450969803
# # Plot histogram of solving times
# plt.hist(solving_times, bins=10, alpha=0.6, color='g', density=True, label='Solving Times')

# # Fit a normal distribution to the solving times
# mu, std = norm.fit(solving_times)
# xmin, xmax = plt.xlim()
# x = np.linspace(xmin, xmax, 100)
# p = norm.pdf(x, mu, std)
# plt.plot(x, p, 'k', linewidth=2, label=f'Dist of Evaluations time: $\mu={mu:.2f}, \sigma={std:.2f}$')

# # Plot the theoretical normal distribution
# p_theoretical = norm.pdf(x, t, st1)
# plt.plot(x, p_theoretical, 'r--', linewidth=2, label=f'Non-optimized model (using h_min): $\mu={t}, \sigma={st1:.10f}$')
# # tt=(N*B*tc)/2
# p_theoretical2 = norm.pdf(x, t, st2)
# plt.plot(x, p_theoretical2, 'b--', linewidth=2, label=f'Optimized model (using tuned h): $\mu={t}, \sigma={st2:.10f}$')

# # Adding labels and title
# plt.title("Comparison of Solving Time Distribution")
# plt.xlabel('Solving Time (seconds)')
# plt.ylabel('Density')
# plt.legend()

# # Show the plot
# plt.show()

##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def E2(seed, taps, n, L):
    """
    Generate L n-bit vectors from an n-bit seed using an LFSR.
    Args:
    - seed (int): Initial seed as an integer.
    - taps (list): Positions used for the feedback, based on the feedback polynomial.
    - n (int): The bit length of the register.
    - L (int): Number of n-bit vectors to generate.

    Returns:
    - list of integers: Each integer represents an n-bit vector.
    """
    state = seed  # Initial state of the LFSR
    output = []
    
    for _ in range(L):
        vector = 0
        for bit_position in range(n):
            next_bit = 0
            # Calculate the feedback bit
            for t in taps:
                if t <= n:  # Ensure tap positions do not exceed the state width
                    next_bit ^= (state >> (n - t)) & 1
                    print("next_bit: ", next_bit)
            # Shift the register and add the new bit
            state = ((state << 1) | next_bit) & ((1 << n) - 1)  # Mask to n bits immediately after shifting
        output.append(state)  # Append the current state
    
    return output
 ##Test Parameters
n = 256  # Number of bits
L = 256   # Number of sequences to generate
taps = [256, 255, 1]  # Feedback taps, simple case

# Seed should be within the limit of n bits
seed = 0b1  # Just a simple initial state

# Execute
output_vectors = E2(seed, taps, n, L)
print(output_vectors)

# s0 = 12345  # example seed
# taps = [1, 0, 1, 1]  # example taps
# lambda_ = 10  # length of the binary vector
# B = 5  # number of vectors to generate


# def E2(seed, taps, n, L):
#     """
#     Generate L n-bit vectors from an n-bit seed using an LFSR.
#     Args:
#     - seed (int): Initial seed as an integer.
#     - taps (list): Positions used for the feedback, based on the feedback polynomial.
#     - n (int): The bit length of the register.
#     - L (int): Number of n-bit vectors to generate.

#     Returns:
#     - list of integers: Each integer represents an n-bit vector.
#     """
#     state = seed  # Initial state of the LFSR
#     output = []
    
#     for _ in range(L):
#         vector = 0
#         for _ in range(n):
#             next_bit = 0
#             # Calculate the feedback bit
#             for t in taps:
#                 next_bit ^= (state >> (n - t)) & 1
#             # Shift the register and add the new bit
#             state = (state << 1) | next_bit
#             state &= (1 << n) - 1  # Keep it to n bits
#             vector = (vector << 1) | next_bit  # Append bit to the output vector
        
#         output.append(vector)
    
#     return output
# sii=[]
# for j in range(B):
# 	sii.append(E2(s0, taps, lambda_, B)) 

# # Generating a list of binary vectors using list comprehension
# si = [E2(s0, taps, lambda_, B) for _ in range(B)] 
# # Printing the results
# print("Generated binary vectors:")
# for index, vector in enumerate(si):
#     print(f"Vector {index + 1}: {vector}")
# print("si:",si)
# print("sii:",sii)

# if sii==si:
#      print("equal.")
# ##--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# lambda_ = 256  # Total number of bits
# num_bytes = lambda_ // 8  # Convert bits to bytes (32 bytes)
# initial_seed = os.urandom(num_bytes).hex()  # Generate random bytes and convert to hex

# # Calculate the number of segments
# num_segments = lambda_ // 64  # Each segment is 64 bits, so lambda_ / 64 segments
# bits_per_segment = 64  # Number of bits in each segment
# hex_chars_per_segment = bits_per_segment // 4  # Convert bits to hex characters (16 hex characters)

# # Divide the initial seed into segments
# segments = [initial_seed[i:i + hex_chars_per_segment] for i in range(0, len(initial_seed), hex_chars_per_segment)]

# print("Initial seed (hexadecimal):", initial_seed)
# print("Divided into segments:", segments)

# import os

# lambda_ = 256  # Number of bits
# num_bytes = lambda_ // 8  # Convert bits to bytes
# initial_seed = os.urandom(num_bytes).hex()  # Generate random bytes and convert to hex

# # Convert the hex string to a binary string
# binary_seed = bin(int(initial_seed, 16))[2:].zfill(num_bytes * 8)

# # Calculate the number of chunks
# num_chunks = lambda_ // 64  # Each chunk is 64 bits

# # Split the binary string into 64-bit chunks
# chunks = [binary_seed[i * 64:(i + 1) * 64] for i in range(num_chunks)]
# print("initial_seed:", initial_seed)
# # Print each chunk
# for index, chunk in enumerate(chunks):
#     print(f"Chunk {index + 1}: {chunk} (Length: {len(chunk)})")

#-~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import numpy as np

# # Example value for j
# j = 5

# # Suppose responses[-1] is some string or array with a specific length
# responses = ['exampledata']  # Change this to the actual use case
# length_of_last_response = len(responses[-1])

# # Convert j to binary, remove '0b', and ensure it's a string
# binary_representation = bin(j)[2:]

# # Calculate the number of repetitions needed to at least cover the length
# # Then take as many characters as needed to match the exact length
# full_binary_string = (binary_representation * ((length_of_last_response // len(binary_representation)) + 1))[:length_of_last_response]

# # Convert to a NumPy array of integers (binary digits)
# binary_vector = np.array(list(full_binary_string), dtype=int)

# print("Binary Vector:", binary_vector)
# print("Length of the binary vector:", len(binary_vector))


# import numpy as np

# # Example integer
# j = 5

# # Example response for demonstration (replace this with your actual data)
# responses = ['exampledata']  # this has a length of 11

# # Length of the binary vector should match the length of the last item in responses
# length_of_last_response = len(responses[-1])

# # Convert j to binary, remove '0b', and pad it to fit the required length
# binary_representation = bin(j)[2:].zfill(length_of_last_response)

# # Convert the padded binary string to a NumPy array of integers
# binary_vector = np.array(list(bin(j)[2:].zfill(len(responses[-1]))), dtype=int)

# # Output the binary vector
# print("Binary Vector:", binary_vector)

# Integer value
integer_value = 14492705073913112842309805703743859369073069752306292747233421687869277301046

# Convert to binary and pad to 256 bits
binary_string = bin(integer_value)[2:].zfill(256)  # Remove the '0b' prefix and pad

print("256-bit binary representation:")
print(binary_string)


#-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def aes_encrypt(plaintext, key):
    if not isinstance(plaintext, bytes):
        plaintext = plaintext.encode()  # Convert plaintext to bytes if it's a string
    iv = os.urandom(16)  # Generate a random 16-byte IV
    cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    encrypted = encryptor.update(plaintext) + encryptor.finalize()
    binary_encrypted = ''.join(f'{byte:08b}' for byte in encrypted)  # Convert each byte to a binary string
    binary_iv = ''.join(f'{byte:08b}' for byte in iv)  # Convert IV to binary string
    return binary_iv + binary_encrypted  # Concatenate IV and encrypted data in binary

def aes_decrypt(binary_ciphertext, key):
    iv = bytes(int(binary_ciphertext[i:i+8], 2) for i in range(0, 128, 8))  # First 128 bits for IV
    ciphertext = bytes(int(binary_ciphertext[i:i+8], 2) for i in range(128, len(binary_ciphertext), 8))
    cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    decrypted = decryptor.update(ciphertext) + decryptor.finalize()
    return decrypted.decode('utf-8', errors='ignore')  # Decode as UTF-8, ignore errors for non-text bytes

# Example usage
key = aes_key_from_seed(12345678901234567890)  # Example seed, adjust accordingly
plaintext = "Hello, world!"
encrypted = aes_encrypt(plaintext.encode(), key)
print("Encrypted (binary):", encrypted)
decrypted = aes_decrypt(encrypted, key)
print("Decrypted:", decrypted)
