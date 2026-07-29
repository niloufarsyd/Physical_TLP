import serial
import numpy as np

class PUFDevice:
    def __init__(self, port="COM4", baudrate=1_000_000, timeout=1.0):
        self.ser = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)

    def close(self):
        if self.ser.is_open:
            self.ser.close()

    def eval(self, challenge_bits: np.ndarray) -> np.ndarray:
        """
        Send a 64-bit challenge, receive a 64-bit response.
        Challenge and response are numpy arrays of {0,1}, MSB-first.
        """
        # print("length1: ", (challenge_bits))
        assert len(challenge_bits) == 64, "Challenge must be 64 bits"

        # --- pack 64 bits into 8 bytes, MSB-first per byte ---
        challenge_bytes = self._bits_to_bytes(challenge_bits)
        # print(f"Sending challenge: {challenge_bytes.hex()}")

        # --- send sync + challenge ---
        self.ser.write(b"\xAA" + challenge_bytes)

        # --- receive response (8 bytes) ---
        resp_bytes = self.ser.read(8)
        if len(resp_bytes) != 8:
            raise IOError(f"Timeout or framing error: got {len(resp_bytes)} bytes")

        # --- unpack 8 bytes into 64 bits, MSB-first per byte ---
        response_bits = self._bytes_to_bits(resp_bytes, 64)
        return response_bits

    @staticmethod
    def _bits_to_bytes(bits: np.ndarray) -> bytes:
        """Pack numpy array of 0/1 bits into bytes, MSB-first per byte."""
        bits = np.asarray(bits, dtype=np.uint8)
        assert len(bits) % 8 == 0
        byte_vals = []
        for i in range(0, len(bits), 8):
            b = 0
            for j in range(8):
                b |= (int(bits[i + j]) & 1) << (7 - j)
            byte_vals.append(b)
        return bytes(byte_vals)

    @staticmethod
    def _bytes_to_bits(bb: bytes, out_len: int) -> np.ndarray:
        """Unpack bytes into numpy array of bits, MSB-first per byte."""
        bits = []
        for byte in bb:
            for shift in range(7, -1, -1):
                bits.append((byte >> shift) & 1)
        return np.array(bits[:out_len], dtype=np.uint8)


# import serial

# class PUFDevice:
#     def __init__(self, port='/dev/ttyUSB1', baudrate=1000000):
#         self.ser = serial.Serial(port, baudrate, timeout=1)

#     def eval(self, challenge: bytes) -> bytes:
#         assert len(challenge) == 8  # 64 bits
#         packet = b'\xAA' + challenge  # Simple frame
#         self.ser.write(packet)
#         response = self.ser.read(8)  # Wait for 8-byte response
#         if len(response) != 8:
#             raise IOError("PUF response timeout or length mismatch")
#         return response

#     def close(self):
#         self.ser.close()
