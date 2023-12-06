#! /usr/bin/python3
import sys

def main(file_name: str):
    with open(file_name, 'r') as fh:
        time = int("".join((fh.readline().split())[1:]))
        distance = int("".join((fh.readline().split())[1:]))

        loses = 0
        for hold in range(time - 1):
            s = hold * (time - hold)
            if s <= distance:
                loses += 1
            else:
                break
        print(1 + time - 2 * loses)

main(sys.argv[1])
