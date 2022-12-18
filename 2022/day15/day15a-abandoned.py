#!/bin/env python3
import re

class Sensor(object):
    def __init__(self, scoord, bcoord):
        self.coord = scoord
        self.beacon = bcoord

    def __repr__(self):
        return f"Sensor<{self.coord}, beacon: {self.beacon}>"

    def nobeacon(self):
        distance = abs(self.coord[0] - self.beacon[0]) + abs(self.coord[1] - self.beacon[1])
        for x in range(self.coord[0] - distance, self.coord[0] + distance + 1):
            yspan = distance - abs(self.coord[0] - x)
            for y in range(self.coord[1] - yspan, self.coord[1] + yspan + 1):
                c = (x, y)
                if c != self.coord and c != self.beacon:
                    yield c

CHECK_AT_Y = 2000000
with open("input.txt") as f:
    sensors = []
    for l in f:
        g = re.match(r'Sensor at x=(?P<x>-?\d+), y=(?P<y>-?\d+): closest beacon is at x=(?P<bx>-?\d+), y=(?P<by>-?\d+)', l).groupdict()
        sensors.append(Sensor((int(g["x"]), int(g["y"])), (int(g["bx"]), int(g["by"]))))

print(sensors)
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

for s in sensors:
    field[s.coord] = "S"
    field[s.beacon] = "B"
#print_field(field)

for s in sensors:
    for c in s.nobeacon():
        field.setdefault(c, "#")
#    print_field(field)


xs = [x for (x, _) in field]
minx = min(xs)
maxx = max(xs)
print([field.get((x, CHECK_AT_Y), ".") for x in range(minx, maxx+1)].count("#"))
