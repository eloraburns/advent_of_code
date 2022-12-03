#!/bin/env python3

with open("input.txt") as f:
    sacs = [set(l.strip()) for l in f.readlines()]

groups = list(zip(sacs, sacs[1:], sacs[2:]))[::3]
badges = map(lambda g: g[0].intersection(g[1]).intersection(g[2]).pop(), groups)

def get_priority(c):
    c = ord(c)
    a = ord('a')
    z = ord('z')
    A = ord('A')
    if c in range(a, z + 1):
        return c - a + 1
    else:
        return c - A + 27

priorities = list(map(get_priority, badges))

print(sum(priorities))
