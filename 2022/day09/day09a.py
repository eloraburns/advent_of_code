#!/bin/env python3
from itertools import chain

def do_line(l):
    [direction, amount] = l.strip().split(" ")
    return (direction, int(amount))

def print_trail(t):
    xs = [x for (x, _) in t]
    ys = [y for (_, y) in t]
    maxx = max(xs)
    minx = min(xs)
    maxy = max(ys)
    miny = min(ys)
    for y in range(maxy, miny - 1, -1):
        l = []
        for x in range(minx, maxx + 1):
            if (x, y) in t:
                l.append("*")
            else:
                l.append(".")
        print("".join(l))
    

with open("input.txt") as f:
    instructions = list(chain(*[[d] * a for (d, a) in [do_line(l) for l in f]]))

tailed = {(0,0),}
hx, hy = 0, 0
tx, ty = 0, 0

for i in instructions:
    if i == "R":
        hx += 1
    elif i == "L":
        hx -= 1
    elif i == "U":
        hy += 1
    elif i == "D":
        hy -= 1

    if hx - tx > 1:
        # head is too far right
        tx += 1
        ty = hy
    elif tx - hx > 1:
        # head is too far left
        tx -= 1
        ty = hy
    elif hy - ty > 1:
        # head is too high
        ty += 1
        tx = hx
    elif ty - hy > 1:
        # head is too low
        ty -= 1
        tx = hx

    tailed.add((tx, ty))

print_trail(tailed)

# 236 is too low
# 5902 is just right
print(len(tailed))
