#! /usr/bin/python3
import sys

def main(filename: str):
    with open(filename, 'r') as fh:
        seeds = fh.readline().split()[1:]
        mymap = dict([(int(s), int(s)) for s in seeds])

        for line in fh:
            line = line.rstrip('\n')
            if line == "":
                continue

            if line[-1] == ":":
                mymap = dict([(s, s) for s in mymap.values()])

            else:
                dest_start, src_start, length = map(int, line.split())
                for s in mymap.keys():
                    if s < src_start or s > src_start + length:
                        continue
                    mymap[s] = s - src_start + dest_start

        print(min(mymap.values()))

main(sys.argv[1])
