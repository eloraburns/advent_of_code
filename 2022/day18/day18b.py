#!/bin/env python3
from collections import Counter
from itertools import chain

with open("input.txt") as f:
    voxels = [v.split(",") for v in [l.strip() for l in f]]
    voxels = list(map(lambda v: (tuple(int(i) for i in v)), voxels))
print(f"{voxels}")
#faces = Counter()

X = 0
Y = 1
Z = 2

MIN = min(chain(*voxels)) - 1
MAX = max(chain(*voxels)) + 1
print(f"MIN = {MIN}; MAX = {MAX}")

to_inspect = set([(MIN, MIN, MIN)])
seen = set()
area = 0

while to_inspect:
    #print(f"to_inspect: {to_inspect}")
    x, y, z = to_inspect.pop()

    if x > MIN and (x-1, y, z) not in seen and (x-1, y, z) not in to_inspect and (x-1, y, z) not in voxels:
        to_inspect.add((x-1, y, z))
    if x < MAX and (x+1, y, z) not in seen and (x+1, y, z) not in to_inspect and (x+1, y, z) not in voxels:
        to_inspect.add((x+1, y, z))
    if y > MIN and (x, y-1, z) not in seen and (x, y-1, z) not in to_inspect and (x, y-1, z) not in voxels:
        to_inspect.add((x, y-1, z))
    if y < MAX and (x, y+1, z) not in seen and (x, y+1, z) not in to_inspect and (x, y+1, z) not in voxels:
        to_inspect.add((x, y+1, z))
    if z > MIN and (x, y, z-1) not in seen and (x, y, z-1) not in to_inspect and (x, y, z-1) not in voxels:
        to_inspect.add((x, y, z-1))
    if z < MAX and (x, y, z+1) not in seen and (x, y, z+1) not in to_inspect and (x, y, z+1) not in voxels:
        to_inspect.add((x, y, z+1))

    for c in [
        (x-1, y, z),
        (x+1, y, z),
        (x, y-1, z),
        (x, y+1, z),
        (x, y, z-1),
        (x, y, z+1),
    ]:
        if c in voxels:
            area += 1

    seen.add((x, y, z))



print(area)
