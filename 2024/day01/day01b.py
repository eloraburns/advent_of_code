from collections import Counter
import sys

[left, right] = zip(*[l.strip().split() for l in sys.stdin.readlines()])

rcounts = Counter(int(r) for r in right)

print(sum(int(l) * rcounts.get(int(l), 0) for l in left))
