#!/bin/python3

with open("input.txt") as f:
    t = f.read().strip()
elves = t.split("\n\n")

def elf2calories(t):
    total = 0
    for c in t.split("\n"):
        total += int(c)
    return total

a = list(map(elf2calories, elves))
print(a)
b = max(*a)

print(b)
