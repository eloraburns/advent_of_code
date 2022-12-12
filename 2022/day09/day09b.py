#!/bin/env python3
from itertools import chain

def do_line(l):
    [direction, amount] = l.strip().split(" ")
    return (direction, int(amount))

def print_trail(step, k, t):
    print(f"\n{step}")
    xs = [x for (x, _) in t] + [x for [x, _] in k]
    ys = [y for (_, y) in t] + [y for [_, y] in k]
    maxx = max(xs)
    minx = min(xs)
    maxy = max(ys)
    miny = min(ys)
    for y in range(maxy, miny - 1, -1):
        l = []
        for x in range(minx, maxx + 1):
            if [x, y] in k:
                idx = k.index([x, y])
                if idx == 0:
                    l.append("H")
                else:
                    l.append(f"{idx}")
            elif (x, y) in t:
                l.append("*")
            else:
                l.append(".")
        print("".join(l))
    

with open("input.txt") as f:
    instructions = list(chain(*[[d] * a for (d, a) in [do_line(l) for l in f]]))

tailed = {(0,0),}
knots = [[0,0] for _ in range(10)]

for (idx, i) in enumerate(instructions):
    #print_trail(idx, knots, tailed)

    if i == "R":
        knots[0][0] += 1
    elif i == "L":
        knots[0][0] -= 1
    elif i == "U":
        knots[0][1] += 1
    elif i == "D":
        knots[0][1] -= 1

    for z in range(9):
        if knots[z][0] - knots[z+1][0] == 2 and knots[z][1] - knots[z+1][1] == 2:
            knots[z+1][0] += 1
            knots[z+1][1] += 1
        elif knots[z][0] - knots[z+1][0] == 2 and knots[z+1][1] - knots[z][1] == 2:
            knots[z+1][0] += 1
            knots[z+1][1] -= 1
        elif knots[z+1][0] - knots[z][0] == 2 and knots[z][1] - knots[z+1][1] == 2:
            knots[z+1][0] -= 1
            knots[z+1][1] += 1
        elif knots[z+1][0] - knots[z][0] == 2 and knots[z+1][1] - knots[z][1] == 2:
            knots[z+1][0] -= 1
            knots[z+1][1] -= 1
        elif knots[z][0] - knots[z+1][0] > 1:
            # head is too far right
            knots[z+1][0] += 1
            knots[z+1][1] = knots[z][1]
        elif knots[z+1][0] - knots[z][0] > 1:
            # head is too far left
            knots[z+1][0] -= 1
            knots[z+1][1] = knots[z][1]
        elif knots[z][1] - knots[z+1][1] > 1:
            # head is too high
            knots[z+1][1] += 1
            knots[z+1][0] = knots[z][0]
        elif knots[z+1][1] - knots[z][1] > 1:
            # head is too low
            knots[z+1][1] -= 1
            knots[z+1][0] = knots[z][0]

    tailed.add((knots[-1][0], knots[-1][1]))
    #if idx + 1 in [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 21, 24, 41, 51, 76, 96]:
    #    print_trail(knots, tailed)

print_trail(999, knots, tailed)

# 2448 is too high
# 2445 is just right
print("===")
print(len(tailed))
