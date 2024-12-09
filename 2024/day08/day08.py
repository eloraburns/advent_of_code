from collections import defaultdict
import functools
import sys

class SomeMap:
    def __init__(self, raw_input):
        self._parse(raw_input)

    def _parse(self, raw_input):
        self.antennas = defaultdict(list)
        rows = raw_input.strip().split("\n")
        self.yrange = range(len(rows))
        self.xrange = range(len(rows[0]))
        for (y, l) in enumerate(rows):
            for (x, c) in enumerate(l):
                if c != ".":
                    self.antennas[c].append((x, y))

    def __contains__(self, coords):
        (x, y) = coords
        return x in self.xrange and y in self.yrange

def pairs(l):
    for i in range(len(l)-1):
        for j in range(i+1, len(l)):
            yield (l[i], l[j])

def stride(coords, xdiff, ydiff):
    (x, y) = coords
    while True:
        yield (x, y)
        x += xdiff
        y += ydiff

def part_a(m):
    antinodes = set()
    for ants in m.antennas.values():
        for ((x1, y1), (x2, y2)) in pairs(ants):
            (xdiff, ydiff) = (x2 - x1, y2 - y1)
            if (x1 - xdiff) in m.xrange and (y1 - ydiff) in m.yrange:
                antinodes.add((x1 - xdiff, y1 - ydiff))
            if (x2 + xdiff) in m.xrange and (y2 + ydiff) in m.yrange:
                antinodes.add((x2 + xdiff, y2 + ydiff))
    return len(antinodes)

def part_b(m):
    antinodes = set()
    for ants in m.antennas.values():
        for ((x1, y1), (x2, y2)) in pairs(ants):
            (xdiff, ydiff) = (x2 - x1, y2 - y1)
            for ant in stride((x1, y1), -xdiff, -ydiff):
                if ant in m:
                    antinodes.add(ant)
                else:
                    break
            for ant in stride((x2, y2), xdiff, ydiff):
                if ant in m:
                    antinodes.add(ant)
                else:
                    break
    return len(antinodes)

with open("input.txt") as f:
    input_txt = SomeMap(f.read())

with open("testa.txt") as f:
    testa = SomeMap(f.read())

print("TEST PART A (expect 14)")
print(part_a(testa))
print("TEST PART B (expect 34)")
print(part_b(testa))


print()
print("PART A")
print(part_a(input_txt))

print("PART B")
print(part_b(input_txt))
