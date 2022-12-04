#!/bin/env python3

import re

fully_contained = 0

with open("input.txt") as f:
    for l in f:
        [a,b,c,d] = re.split(r'-|,', l.strip())
        left = set(range(int(a), int(b) + 1))
        right = set(range(int(c), int(d) + 1))
        #if a <= c and b >= d or c <= a and d >= b:
        if left.issuperset(right) or left.issubset(right):
            print(f"Fully contained {l.strip()}")
            fully_contained += 1
        else:
            print(f"Not fully contained {l.strip()}")

# 567 is too high
# 540
print(fully_contained)
