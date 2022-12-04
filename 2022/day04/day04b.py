#!/bin/env python3

import re

has_overlap = 0

with open("input.txt") as f:
    for l in f:
        [a,b,c,d] = re.split(r'-|,', l.strip())
        left = set(range(int(a), int(b) + 1))
        right = set(range(int(c), int(d) + 1))
        #if a <= c and b >= d or c <= a and d >= b:
        if not left.isdisjoint(right):
            has_overlap += 1

print(has_overlap)
