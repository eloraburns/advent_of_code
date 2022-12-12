#!/bin/env python3

class Instruction(object):
    pass

class Noop(Instruction):
    def __str__(self):
        return "noop"

class Addx(Instruction):
    def __init__(self, v):
        self.v = v

    def __str__(self):
        return f"addx {self.v}"

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
current_row = []

def draw(i):
    x = cycle % 40
    if abs(reg_x - x) < 2:
        #current_row.append("#")
        print("#", end="")
    else:
        #current_row.append(".")
        print(".", end="")
    if x == 39:
        print()
    #print(f"*** <{i}> reg_x={reg_x}, cycle={cycle}\n    {''.join(current_row)}")

for i in instructions:
    if isinstance(i, Noop):
        draw(i)
        cycle += 1
    elif isinstance(i, Addx):
        draw(i)
        cycle += 1
        draw(i)
        reg_x += i.v
        cycle += 1
    #if cycle > 22:
    #    break

