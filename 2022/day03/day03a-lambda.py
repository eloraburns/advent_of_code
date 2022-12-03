#!/bin/env python3

with open("input.txt") as f:
    sacs = [[set(s[:len(s)//2]), set(s[len(s)//2:])] for s in [l.strip() for l in f.readlines()]]

commons = [s[0].intersection(s[1]).pop() for s in sacs]
priorities = list(map(lambda c: ('a' <= c <= 'z' and ord(c) - ord('a') + 1) or (ord(c) - ord('A') + 27), commons))
print(sum(priorities))
