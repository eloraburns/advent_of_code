#!/bin/env python3

with open("input.txt") as f:
    moves = [l.strip() for l in f.readlines()]

guide = {
  "A X": 1 + 3,
  "A Y": 2 + 6,
  "A Z": 3 + 0,
  "B X": 1 + 0,
  "B Y": 2 + 3,
  "B Z": 3 + 6,
  "C X": 1 + 6,
  "C Y": 2 + 0,
  "C Z": 3 + 3
}

score = sum(guide[l] for l in moves)

print(score)
