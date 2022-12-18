#!/bin/env python3
import itertools
from pprint import pprint

def expand_scan_line(l):
    coords = [(int(x[0]), int(x[1])) for x in [c.split(",") for c in l.split(" -> ")]]
    return list(zip(coords, coords[1:]))

with open("input.txt") as f:
    lines = list(itertools.chain(*(expand_scan_line(l.strip()) for l in f.readlines())))

field = {(500, 0): "+"}

def print_field(f):
    xs = [x for (x, _) in f]
    minx = min(xs)
    maxx = max(xs)
    ys = [y for (_, y) in f]
    ys.append(0)
    miny = min(ys)
    maxy = max(ys)
    print("VVVVV")
    for y in range(miny, maxy+1):
        print("".join(f.get((x, y), ".") for x in range(minx, maxx+1)))
    print("^^^^^")

for ((x1, y1), (x2, y2)) in lines:
    if x1 == x2:
        if y1 > y2:
            y1, y2 = y2, y1
        for y in range(y1, y2+1):
            field[(x1, y)] = "#"
    else:
        if x1 > x2:
            x1, x2 = x2, x1
        for x in range(x1, x2+1):
            field[(x, y1)] = "#"

maxy = max(y for (_, y) in field)
sand_units = 0
filling = True
while filling: # for each unit of sand
    x = 500
    for y in range(0, maxy+2):
        if (x, y+1) not in field:
            pass
        elif (x-1, y+1) not in field:
            x -= 1
        elif (x+1, y+1) not in field:
            x += 1
        else:
            field[(x, y)] = "o"
            print_field(field)
            break
    else:
        filling = False

print(list(field.values()).count("o"))
