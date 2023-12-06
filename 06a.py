#! /usr/bin/python3
import sys

def main(file_name: str):
    with open(file_name, 'r') as fh:
        times = list(map(int, (fh.readline().split())[1:]))
        distances = list(map(int, (fh.readline().split())[1:]))

        score = 1
        for i, time in enumerate(times):
            wins = 0
            for hold in range(time - 1):
                s = hold * (time - hold)
                if s > distances[i]:
                    wins += 1
            score *= wins
        print(score)

main(sys.argv[1])
