#!/bin/env python3
from pprint import pprint

with open("input.txt") as f:
    [input_state, input_instructions] = f.read().split("\n\n")

input_lines = input_state.split("\n")[:-1]
stacks = [
    list(reversed(s))
    for s in zip(*[
        [c for c in l[1::4]]
        for l in input_lines
    ])
]

for s in stacks:
    while s[-1] == " ":
        s.pop()

stacks.insert(0, []) # to make 1-based indexing work

# pprint(stacks)

instructions = []
for i in input_instructions.strip().split("\n"):
    [_, n, _, source, _, dest] = i.split()
    instructions.append((int(n), int(source), int(dest)))

for (n, s, d) in instructions:
    stacks[d].extend(stacks[s][-n:])
    stacks[s] = stacks[s][:-n]

print("".join(stack[-1] for stack in stacks if stack))
