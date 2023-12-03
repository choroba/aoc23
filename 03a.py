#! /usr/bin/python3
import sys

def adjacent(n, y, symbol):
    for j in y - 1, y, y + 1:
        if j in symbol:
            for x in symbol[j]:
                if x <= n[1] and x >= n[0]:
                    return True
    return False

DIGITS = {*map(str, range(10))}

number={}
symbol={}
with open(sys.argv[1], 'r') as fh:
    y = 0
    for line in fh:
        line = line.rstrip('\n')
        number[y] = []
        symbol[y] = []
        x = 0
        while x < len(line):
            if line[x] not in DIGITS | {'.'}:
                symbol[y] += [x]
            elif line[x] != '.':
                to = x + 1
                while to < len(line) and line[to] in DIGITS:
                    to += 1
                number[y] += [(x - 1, to, int(line[x:to]))]
                x = to - 1
            x += 1
        y += 1

sum = 0
for y in number:
    for n in number[y]:
        if adjacent(n, y, symbol):
            sum += n[2]
print(sum)
