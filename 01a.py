#! /usr/bin/python3
import sys

DIGITS = set(map(str, range(1, 10)))

with open(sys.argv[1], 'r') as fh:
    calibration = 0
    for line in fh:
        digits = [d for d in line if d in DIGITS]
        add = 10 * int(digits[0]) + int(digits[-1])
        calibration += add
print(calibration)
