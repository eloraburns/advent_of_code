import sys

reports = [[int(d) for d in l.split()] for l in sys.stdin.readlines()]

def is_safe(report):
    deltas = [b - a for (a, b) in zip(report[:-1], report[1:])]
    if -3 <= min(deltas) and max(deltas) <= -1 or 1 <= min(deltas) and max(deltas) <= 3:
        return True
    else:
        return False

def is_actually_safe(report):
    for i in range(0, len(report)):
        if is_safe(report[:i] + report[i+1:]):
            return True
    return False

print("PART A")
print(sum(is_safe(report) for report in reports))

print()
print("PART B")
print(sum(is_actually_safe(report) for report in reports))
