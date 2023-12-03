#! /usr/bin/python3
import sys

number={}
star={}
with open(sys.argv[1], 'r') as fh:
    y = 0
    for line in fh:
        number[y] = []
        star[y] = []
        x = 0
        while x < len(line):
            if line[x] == '*':
                star[y] += [x]
            elif line[x] in map(str, range(10)):
                to = x + 1
                while to < len(line) and line[to] in map(str, range(10)):
                    to += 1
                number[y] += [(x - 1, to, int(line[x:to]))]
                x = to - 1
            x += 1
        y += 1

sum = 0
for y in star:
    for x in star[y]:
        adjacent = []
        for j in y - 1, y, y + 1:
            if j in number:
                adjacent += [n[2] for n in number[j]
                             if x >= n[0] and x <= n[1]]
        if len(adjacent) == 2:
            sum += adjacent[0] * adjacent[1]
print(sum)
