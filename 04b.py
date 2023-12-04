#! /usr/bin/python3
import sys
from typing import Dict

def main(filename: str):
    card: Dict[int, int] = {}
    with open(filename, 'r') as fh:
        for line in fh:
            name, rest = line.split(':')
            cid = int(name.split()[1])
            winning0, yours0 = rest.split('|')
            winning = winning0.split()
            yours = yours0.split()
            card[cid] = card.get(cid, 0) + 1

            matches = [w for w in winning if w in yours]
            for i in range(1, len(matches) + 1):
                card[cid + i] = card.get(cid + i, 0) + card[cid]
    print(sum(card.values()))

main(sys.argv[1])
