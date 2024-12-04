import sys

print(sum([abs(a - b) for (a, b) in zip(*[sorted(int(n) for n in t) for t in zip(*[l.strip().split() for l in sys.stdin.readlines()])])]))

