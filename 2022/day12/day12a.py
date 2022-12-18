#!/bin/env python3
import collections
import heapq
import pprint
import sys

with open("input.txt") as f:
    topo = [[ord(c) for c in l.strip()] for l in f]

minx = 0
maxx = len(topo[0]) - 1
miny = 0
maxy = len(topo) - 1

for y in range(maxy + 1):
    for x in range(maxx + 1):
        if topo[y][x] == ord("S"):
            sx, sy = x, y
            topo[y][x] = ord("a")
        elif topo[y][x] == ord("E"):
            ex, ey = x, y
            topo[y][x] = ord("z")
#pprint.pprint(topo)

def print_pathmap():
    print("=====")
    for y in range(maxy+1):
        for x in range(maxx+1):
            sigil = " "
            if (x, y) == (sx, sy):
                sigil = "<"
            elif (x, y) == (ex, ey):
                sigil = ">"
            elif (x, y) in seen:
                sigil = "S"
            elif ToCheck(x, y) in to_check:
                sigil = "C"
            elif (x, y) == (cx, cy):
                sigil = "*"
            print(f"{min(pathmap[(x, y)], maxx*maxy):3x}{sigil}", end="")
        print()

class ToCheck(object):
    def __init__(self, x, y, distance=sys.maxsize):
        self.coords = (x, y)

    def __lt__(self, other):
        return pathmap[self.coords] < pathmap[other.coords]

    def __eq__(self, other):
        return self.coords == other.coords

    def __repr__(self):
        return f"ToCheck<{self.coords}, {pathmap[self.coords]}>"

print(sx, sy, ex, ey)
pathmap = collections.defaultdict(lambda: sys.maxsize, {(sx, sy): 0})
seen = set()
to_check = [ToCheck(sx, sy)]
while to_check:
    cx, cy = heapq.heappop(to_check).coords
    print_pathmap()
    print(f"current: {cx}, {cy}")
    print(f"seen: {seen}")
    print(f"to_check: {to_check}")

    if cx-1 >= minx and (cx-1, cy) not in seen and topo[cy][cx-1] <= topo[cy][cx] + 1 and pathmap[(cx-1, cy)] > pathmap[(cx, cy)]:
        t = ToCheck(cx-1, cy)
        if t not in to_check: heapq.heappush(to_check, t)
        pathmap[(cx-1, cy)] = pathmap[(cx, cy)] + 1

    if cx+1 <= maxx and (cx+1, cy) not in seen and topo[cy][cx+1] <= topo[cy][cx] + 1 and pathmap[(cx+1, cy)] > pathmap[(cx, cy)]:
        t = ToCheck(cx+1, cy)
        if t not in to_check: heapq.heappush(to_check, t)
        pathmap[(cx+1, cy)] = pathmap[(cx, cy)] + 1

    if cy-1 >= miny and (cx, cy-1) not in seen and topo[cy-1][cx] <= topo[cy][cx] + 1 and pathmap[(cx, cy-1)] > pathmap[(cx, cy)]:
        t = ToCheck(cx, cy-1)
        if t not in to_check: heapq.heappush(to_check, t)
        pathmap[(cx, cy-1)] = pathmap[(cx, cy)] + 1

    if cy+1 <= maxy and (cx, cy+1) not in seen and topo[cy+1][cx] <= topo[cy][cx] + 1 and pathmap[(cx, cy+1)] > pathmap[(cx, cy)]:
        t = ToCheck(cx, cy+1)
        if t not in to_check: heapq.heappush(to_check, t)
        pathmap[(cx, cy+1)] = pathmap[(cx, cy)] + 1

    seen.add((cx, cy))

# 354 is too high
# 352
print(pathmap[(ex, ey)])
