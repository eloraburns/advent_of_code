#!/bin/env python3
import itertools
import re
import time


class Sensor(object):
    def __init__(self, scoord, bcoord):
        self.coord = scoord
        self.beacon = bcoord
        self.range = self.detection_range()

    def __repr__(self):
        return f"Sensor<{self.coord}, beacon: {self.beacon}>"

    @staticmethod
    def dist(a, b):
        return abs(a[0] - b[0]) + abs(a[1] - b[1])

    def detection_range(self):
        return self.dist(self.coord, self.beacon)

    def is_in_range(self, c):
        distance = self.dist(self.coord, c)
        return distance <= self.range

    def fringe(self):
        for x in range(-self.range - 1, self.range + 2):
            spread = self.range + 1 - abs(x)
            yield (self.coord[0] + x, self.coord[1] + spread)
            yield (self.coord[0] + x, self.coord[1] - spread)

field = {}
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

#BOUNDS = 20
#with open("test.txt") as f:
BOUNDS = 4000000
with open("input.txt") as f:
    sensors = []
    for l in f:
        g = re.match(r'Sensor at x=(?P<x>-?\d+), y=(?P<y>-?\d+): closest beacon is at x=(?P<bx>-?\d+), y=(?P<by>-?\d+)', l).groupdict()
        sensors.append(Sensor((int(g["x"]), int(g["y"])), (int(g["bx"]), int(g["by"]))))

print(sensors)
print()
#for s in sensors:
#    field[s.coord] = "S"
#    field[s.beacon] = "B"
##print_field(field)
#for s in sensors:
#    for c in s.fringe():
#        field.setdefault(c, "X")
#print_field(field)


maxdistance = max(s.detection_range() for s in sensors)
beacons = set(s.beacon for s in sensors)

print("filtering")
fringes = filter(
    lambda c: 0 <= c[0] <= BOUNDS and 0 <= c[1] <= BOUNDS,
    itertools.chain(*(s.fringe() for s in sensors))
)
#start = time.time()
##lfringes = list(fringes)
##print(f"Fringes have {len(lfringes)} locations to check")
#print(f"(but we can reduce it to {len(set(fringes))} if we want)")
#end = time.time()
#print(f"(took {end-start}s)")

#print(sum(
#    any([s.is_in_range((x, CHECK_AT_Y)) for s in sensors])
#    for x in range(minx, maxx+1)
#    if (x, CHECK_AT_Y) not in beacons
#))

start = time.time()
for (i, c) in enumerate(fringes):
    if i % 100000 == 0:
        print(f'{i}/{int(time.time()-start)}s, ', end="", flush=True)
    if all(not s.is_in_range(c) for s in sensors):
        print(f"\n==> {c[0]*4000000 + c[1]}")
        break
end = time.time()
print(f"Took {int(end-start)}s")
