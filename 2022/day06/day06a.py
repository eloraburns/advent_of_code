#!/bin/env python3

with open("input.txt") as f:
    signal = f.read()

signal_iter = iter(signal)
received = [None, next(signal_iter), next(signal_iter), next(signal_iter)]
place = 3

for c in signal_iter:
    received = received[1:]
    received.append(c)
    place += 1
    if len(set(received)) == 4:
        break

print(place)
