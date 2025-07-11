import math

def generate_sine_lut(addr_bits=10, data_bits=18):
    lut_size = 2**addr_bits
    max_val = 2**(data_bits-1) - 1
    
    with open("sine_lut.mem", 'w') as f:
        for i in range(lut_size):
            angle = (2 * math.pi * i) / lut_size
            sine_val = int(round(math.sin(angle) * max_val))
            if sine_val < 0:
                sine_val += 2**data_bits