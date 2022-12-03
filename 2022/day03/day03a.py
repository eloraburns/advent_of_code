#!/bin/env python3

with open("input.txt") as f:
    sacs = [[set(s[:len(s)//2]), set(s[len(s)//2:])] for s in [l.strip() for l in f.readlines()]]

commons = [s[0].intersection(s[1]).pop() for s in sacs]

def get_priority(c):
    c = ord(c)
    a = ord('a')
    z = ord('z')
    A = ord('A')
    if c in range(a, z + 1):
        return c - a + 1
    else:
        return c - A + 27

priorities = list(map(get_priority, commons))

print(sum(priorities))
