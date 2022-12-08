#!/bin/env python3

with open("input.txt") as f:
    m = list(map(str.strip, f.readlines()))

HEIGHT = len(m)
WIDTH = len(m[0])

visible = set()

# From the left
for y in range(HEIGHT):
    prev_max = "/"
    for x in range(WIDTH):
        if m[y][x] > prev_max:
            visible.add((x, y))
            prev_max = m[y][x]

# From the right
for y in range(HEIGHT):
    prev_max = "/"
    for x in range(WIDTH-1, 0-1, -1):
        if m[y][x] > prev_max:
            visible.add((x, y))
            prev_max = m[y][x]

# From the top
for x in range(WIDTH):
    prev_max = "/"
    for y in range(HEIGHT):
        if m[y][x] > prev_max:
            visible.add((x, y))
            prev_max = m[y][x]

# From the bottom
for x in range(WIDTH):
    prev_max = "/"
    for y in range(HEIGHT-1, 0-1, -1):
        if m[y][x] > prev_max:
            visible.add((x, y))
            prev_max = m[y][x]

print(len(visible))
        
