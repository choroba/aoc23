#! /usr/bin/python3
import sys

VALUE = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
         'seven': 7, 'eight': 8, 'nine': 9}
DIGITS = (*map(str, range(1, 10)), *VALUE.keys())

def value(digit: str) -> int:
    return int(digit) if len(digit) == 1 else VALUE[digit]

with open(sys.argv[1], 'r') as fh:
    calibration = 0
    for line in fh:
        left = (len(line), 0)
        right = (-1, 0)
        for d in DIGITS:
            pos = line.find(d)
            if pos > -1 and pos < left[0]:
                left = (pos, value(d))
            pos = line.rfind(d)
            if pos > right[0]:
                right = (pos, value(d))
        add = 10 * left[1] + right[1]
        calibration += add
print(calibration)
