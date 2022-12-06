#!/bin/env python3

LOOKING_FOR=14

with open("input.txt") as f:
    signal = f.read()

signal_iter = iter(signal)
received = [None]
for _ in range(LOOKING_FOR - 1):
    received.append(next(signal_iter))
place = LOOKING_FOR - 1

for c in signal_iter:
    received = received[1:]
    received.append(c)
    place += 1
    if len(set(received)) == LOOKING_FOR:
        break

print(place)
