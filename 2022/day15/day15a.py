#!/bin/env python3
import re


class Sensor(object):
    def __init__(self, scoord, bcoord):
        self.coord = scoord
        self.beacon = bcoord
        self.range = self.detection_range()

    def __repr__(self):
        return f"Sensor<{self.coord}, beacon: {self.beacon}>"

    def detection_range(self):
        return abs(self.coord[0] - self.beacon[0]) + abs(self.coord[1] - self.beacon[1])

    def is_in_range(self, c):
        distance = abs(self.coord[0] - c[0]) + abs(self.coord[1] - c[1])
        return distance <= self.range


#CHECK_AT_Y = 10
#with open("test.txt") as f:
CHECK_AT_Y = 2000000
with open("input.txt") as f:
    sensors = []
    for l in f:
        g = re.match(r'Sensor at x=(?P<x>-?\d+), y=(?P<y>-?\d+): closest beacon is at x=(?P<bx>-?\d+), y=(?P<by>-?\d+)', l).groupdict()
        sensors.append(Sensor((int(g["x"]), int(g["y"])), (int(g["bx"]), int(g["by"]))))

print(sensors)
print()

maxdistance = max(s.detection_range() for s in sensors)
beacons = set(s.beacon for s in sensors)

xs = [s.coord[0] for s in sensors]
minx = min(xs) - maxdistance
maxx = max(xs) + maxdistance
print(sum(
    any([s.is_in_range((x, CHECK_AT_Y)) for s in sensors])
    for x in range(minx, maxx+1)
    if (x, CHECK_AT_Y) not in beacons
))
