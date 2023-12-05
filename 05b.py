#! /usr/bin/python3
import sys

def main(filename: str):
    with open(filename, 'r') as fh:
        seeds = list(map(int, fh.readline().split()[1:]))
        mymap = [(seeds[i * 2], seeds[i * 2] + seeds[i * 2 + 1] - 1, 0)
                 for i in range(0, len(seeds) // 2)]

        for line in fh:
            line = line.rstrip('\n')
            if line == "":
                continue

            if line[-1] == ':':
                mymap = [(e[0] + e[2], e[1] + e[2], 0) for e in mymap]

            else:
                dest_start, src_start, length = map(int, line.split())
                rest = []
                for i, e in enumerate(mymap):
                    frm, to, shift = e
                    i0, i1 = src_start, src_start + length - 1
                    if i1 < frm or i0 > to:
                        continue

                    if i0 < frm:
                        i0 = frm
                    elif i0 > frm:
                        rest += [(frm, i0 - 1, shift)]

                    if i1 > to:
                        i1 = to
                    elif i1 < to:
                        rest += [(i1 + 1, to, shift)]

                    mymap[i] = (i0, i1, dest_start - src_start)
                mymap += rest

        print(min([e[0] + e[2] for e in mymap]))

main(sys.argv[1])
