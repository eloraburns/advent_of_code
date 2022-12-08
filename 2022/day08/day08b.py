#!/bin/env python3

with open("input.txt") as f:
    m = list(map(str.strip, f.readlines()))

HEIGHT = len(m)
WIDTH = len(m[0])

best_score = 0

for y in range(HEIGHT):
    print(".", end="")
    for x in range(WIDTH):
        this_tree = m[y][x]

        left = 0
        for x2 in range(x - 1, -1, -1):
            left += 1
            if m[y][x2] >= this_tree:
                break

        right = 0
        for x2 in range(x + 1, WIDTH):
            right += 1
            if m[y][x2] >= this_tree:
                break

        up = 0
        for y2 in range(y - 1, -1, -1):
            up += 1
            if m[y2][x] >= this_tree:
                break

        down = 0
        for y2 in range(y + 1, HEIGHT):
            down += 1
            if m[y2][x] >= this_tree:
                break

        score = left * right * up * down
        best_score = max(score, best_score)

# 1479 is too low
print(f"\n{best_score}")
