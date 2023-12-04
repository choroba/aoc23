#! /usr/bin/python3
import sys

def main(filename: str):
    points = 0
    with open(filename, 'r') as fh:
        for line in fh:
            name, rest = line.split(':')
            name = name.split()[1]
            winning0, yours0 = rest.split('|')
            winning = winning0.split()
            yours = yours0.split()

            matches = [w for w in winning if w in yours]
            if matches:
                points += 1 << (len(matches) - 1)
    print(points)

main(sys.argv[1])
