###============================
import serial
import time
import random
from collections import Counter

# open UART (adjust port name!)
ser = serial.Serial(port="COM4", baudrate=1_000_000, timeout=3)

# 1) Send a 16-byte "challenge"
# challenge = bytes([0xAA]*8)   # example: all 0xAA

# challenge= bytes([0xAA])  + bytes([0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef])
# challenge= bytes([0xAA])  + bytes([0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0x11])
# challenge= bytes([0xAA])  + bytes([0x33, 0xcd, 0xef, 0xaa, 0x22, 0xa0, 0xad, 0xef])
challenge= bytes([0xAA])  + bytes([0xcc, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0x24])
# challenge= bytes([0xAA])  + bytes([0x77, 0xaa, 0x22, 0x05, 0x33, 0x22, 0xcd, 0x22])

print("Sending:", challenge.hex())
time1 = time.time()
ser.write(challenge)

# 2) Read back (if your FPGA echoes)
resp = ser.read(8)
time2 = time.time()
print("Received:", resp.hex())
resp_val = int.from_bytes(resp, byteorder="big")
# print(f"Response value (hex): {resp_val:016x}")
print(f"Time taken (s): {time2 - time1:.6f}")
# 3) Close
ser.close()

###---------------------------------------------

# ----------------------------
# Configuration
# ----------------------------
PORT = "COM4"
BAUD = 1_000_000
NUM_TRIALS = 1000        # number of times to repeat the same challenge
RESPONSE_BITS = 64       # response length (bits)
# CHALLENGE = bytes([0xAA, 0xff, 0x23, 0x45, 0x67, 0x89, 0xab, 0xCD, 0x11])

# ----------------------------
# Open serial
# ----------------------------
ser = serial.Serial(port=PORT, baudrate=BAUD, timeout=2)

print(f"Sending the same challenge {NUM_TRIALS} times...")


def bytes_to_bits(b):
    """Convert bytes to list of bits (MSB first)."""
    bits = []
    for byte in b:
        for i in range(8):
            bits.append((byte >> (7 - i)) & 1)
    return bits

def hamming_distance(a, b):
    """Compute Hamming distance between two bit lists."""
    return sum(x != y for x, y in zip(a, b))

responses = []

for t in range(NUM_TRIALS):
    ser.write(challenge)
    resp = ser.read(8)  # 8 bytes = 64 bits
    if len(resp) != 8:
        print(f"Trial {t}: No valid response!")
        continue
    responses.append(bytes_to_bits(resp))

ser.close()
print(f"Collected {len(responses)} responses.")

# ----------------------------
# Reliability (repeatability)
# ----------------------------
if len(responses) < 2:
    print("Not enough responses for reliability analysis.")
else:
    ref = responses[0]
    dists = [hamming_distance(ref, r) for r in responses]
    mean_flip = sum(dists) / (len(dists) * RESPONSE_BITS)
    reliability = 1 - mean_flip
    print(f"Average bit flip rate: {mean_flip*100:.3f}%")
    print(f"Reliability: {reliability*100:.3f}%")

# ----------------------------
# Uniformity (bias in bits)
# ----------------------------
all_bits = [b for resp in responses for b in resp]
count = Counter(all_bits)
ones = count[1]
zeros = count[0]
uniformity = ones / (ones + zeros) if (ones + zeros) > 0 else 0
print(f"Uniformity: {uniformity*100:.3f}% (ideal = 50%)")


# from puf_bridge import PUFDevice
# # from tlp_gen import puz_device
# import numpy as np
# import serial
# # # ###def puz_device(k, x, lambda_, eval_device):

# # # dev = PUFDevice("/dev/ttyUSB1", baudrate=1_000_000)
# # # k, r = puz_device(5, 1, 64, dev)
# # # print("k=", k, "response length=", len(r), "bits")
# # # print(r)

# # ##-------------------

# ser = serial.Serial("COM4", baudrate=460800, timeout=2)
# ser.write(b"\xAA" + b"\x00"*8)   # sync + 128-bit zero challenge
# # # resp = ser.read(8)
# # # print("Got", len(resp), "bytes:", resp.hex())
# # # print(resp)
# # # ser.close()


# # dev = PUFDevice(port="COM4", baudrate=1_000_000, timeout=2.0)

# # # # # all-zero challenge
# # challenge = np.zeros(64, dtype=np.uint8)
# # resp = dev.eval(challenge)

# # # print("Challenge (bits):", challenge)
# # # print("Response length :", len(resp), "bits")
# # # print("Response bits   :", resp)

# # # dev.close()

# # import serial

# # ser = serial.Serial("COM4", baudrate=115200)

# # challenge = bytes([0xAA]*8)  # example 128-bit challenge (16 bytes)
# # ser.write(challenge)

# # # read echo
# # resp = ser.read(8)
# print("Echo:")
###============================
# import serial
# import time

# # open UART (adjust port name!)
# ser = serial.Serial(port="COM4", baudrate=1_000_000, timeout=3)

# # 1) Send a 16-byte "challenge"
# # challenge = bytes([0xAA]*8)   # example: all 0xAA
# challenge= bytes([0xAA])  + bytes([0x33,0x33,0x45,0x11,0x22,0xdd,0x33,0x44])
# print("Sending:", challenge.hex())
# ser.write(challenge)

# # 2) Read back (if your FPGA echoes)
# resp = ser.read(8)
# print("Received:", resp.hex())
# resp_val = int.from_bytes(resp, byteorder="big")
# print(f"Response value (hex): {resp_val:016x}")
# # 3) Close
# ser.close()
###============================
# import serial
# import time

# # Open the UART (adjust COM port!)
# ser = serial.Serial(port="COM4", baudrate=1000000, timeout=10)

# # Test pattern
# pattern = [0xAA, 0x55]  # 0xAA = 10101010, 0x55 = 01010101

# for i in range(10):
#     # Pick alternating value
#     byte = pattern[i % 2]
#     ser.write(bytes([byte]))
#     print(f"Sent: 0x{byte:02X}")
#     time.sleep(0.5)  # wait 0.5s so you can see LED blink

# ser.close()
