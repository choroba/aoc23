#! /usr/bin/python3
import sys

from typing import List, Tuple, Dict

def adjacent(n: Tuple[int, int, int], y: int, symbol: Dict[int, List[int]]):
    for j in y - 1, y, y + 1:
        if j in symbol:
            for x in symbol[j]:
                if x <= n[1] and x >= n[0]:
                    return True
    return False

DIGITS = {*map(str, range(10))}

def main(input_file: str):
    number: Dict[int, List[Tuple[int, int, int]]] = {}
    symbol: Dict[int, List[int]] = {}
    with open(input_file, 'r') as fh:
        y = 0
        for line in fh:
            line = line.rstrip('\n')
            number[y] = []
            symbol[y] = []
            x = 0
            while x < len(line):
                if line[x] in DIGITS:
                    to = x + 1
                    while to < len(line) and line[to] in DIGITS:
                        to += 1
                    number[y] += [(x - 1, to, int(line[x:to]))]
                    x = to - 1
                elif line[x] != '.':
                    symbol[y] += [x]
                x += 1
            y += 1

    sum = 0
    for y in number:
        for n in number[y]:
            if adjacent(n, y, symbol):
                sum += n[2]
    print(sum)

main(sys.argv[1])
