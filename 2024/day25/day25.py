from collections import namedtuple
from itertools import groupby

with open("testa.txt") as f:
    testa_raw_items = f.read().strip().split("\n\n")

with open("input.txt") as f:
    input_raw_items = f.read().strip().split("\n\n")

Lock = namedtuple('Lock', 'a b c d e'.split())
Key = namedtuple('Key', 'a b c d e'.split())

def parse(raw_item):
    lines = raw_item.split("\n")
    depths = [0] * 5
    if raw_item[0][0] == '#':
        class_ = Lock
    else:
        class_ = Key
        lines.reverse()

    for l in lines[1:-1]:
        for (i, c) in enumerate(l):
            if c == "#":
                depths[i] += 1

    return class_(*depths)

def solvea(raw_items):
    locks = []
    keys = []
    for ri in raw_items:
        p = parse(ri)
        if isinstance(p, Key):
            keys.append(p)
        elif isinstance(p, Lock):
            locks.append(p)
        else:
            raise Exception("wat")
    print(f"There are {len(locks)} locks")
    print(f"There are {len(keys)} keys")
    acc = 0
    for lo in locks:
        for k in keys:
            if all([(a+b)<=5 for (a, b) in zip(lo, k)]):
                acc += 1
    return acc

# print("TEST A (expect 3)")
# print(solvea(testa_raw_items))

print("SOLVE A")
print(solvea(input_raw_items))
