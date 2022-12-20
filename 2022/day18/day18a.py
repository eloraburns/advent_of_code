#!/bin/env python3
from collections import Counter

with open("test.txt") as f:
    voxels = [v.split(",") for v in [l.strip() for l in f]]
    voxels = list(map(lambda v: (tuple(int(i) for i in v)), voxels))
print(f"{voxels}")
faces = Counter()

X = 0
Y = 1
Z = 2

for v in voxels:
    # Each voxel has 6 sides. BUT if we consider tagging them as "faces"
    # that are shared between adjacent voxels, any "surface area" faces
    # will be seen exactly once, and "internal area" faces will be seen
    # exactly twice. We just have to map all faces into a unified
    # coordinate system. (x, y, z, X) means "the face in the positive-x
    # direction from the voxel at (x, y, z). Hence the opposite face
    # is denoted by (x-1, y, z, X), i.e. "the face in the positive-x
    # direction _of the voxel one x coordinate smaller_".
    faces.update([
        (v[0], v[1], v[2], X),
        (v[0], v[1], v[2], Y),
        (v[0], v[1], v[2], Z),
        (v[0] - 1, v[1], v[2], X),
        (v[0], v[1] - 1, v[2], Y),
        (v[0], v[1], v[2] - 1, Z),
    ])

print(sum(c for c in faces.values() if c == 1))
