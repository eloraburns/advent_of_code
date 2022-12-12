#!/bin/env python3

class Instruction(object):
    pass

class Noop(Instruction):
    pass

class Addx(Instruction):
    def __init__(self, v):
        self.v = v

def parse_instruction(l):
    if l.startswith("noop"):
        return Noop()
    else:
        [_, v] = l.strip().split()
        return Addx(int(v))

with open("input.txt") as f:
    instructions = [parse_instruction(l) for l in f]

reg_x = 1
cycle = 0
interesting_cycles = range(20, 221, 40)
strengths = 0

def accumulate_strength():
    global strengths
    if cycle in interesting_cycles:
        print(f"*** ({cycle}, {reg_x}) => {cycle*reg_x}")
        strengths += cycle * reg_x

for i in instructions:
    if isinstance(i, Noop):
        cycle += 1
        accumulate_strength()
    elif isinstance(i, Addx):
        cycle += 1
        accumulate_strength()
        cycle += 1
        accumulate_strength()
        reg_x += i.v

# 16120 is too high
print(strengths)
