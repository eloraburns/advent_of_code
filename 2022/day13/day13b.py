#!/bin/env python3
from functools import total_ordering
from itertools import zip_longest
from pprint import pprint

def make_list(i):
    if isinstance(i, int):
        return [i]
    else:
        return i


@total_ordering
class Packet(object):
    def __init__(self, p):
        self.p = p
        self.i = 0

    @property
    def current(self):
        return self.p[self.i]

    def __repr__(self):
        return f"Packet<{self.i}, {self.p}>"

    def __len__(self):
        return len(self.p)

    def __lt__(self, other):
        return compare(Packet(self.p), Packet(other.p))

    def __eq__(self, other):
        return self.p == other.p


def compare(x, y):
    xs, ys = [x], [y]
    while True:
        xl, yl = xs[-1], ys[-1]
        try:
            if isinstance(xl.current, int) and isinstance(yl.current, int):
                if xl.current < yl.current:
                    return True
                elif xl.current > yl.current:
                    return False
                else:
                    xl.i += 1
                    yl.i += 1
                    continue
            xl1 = Packet(make_list(xl.current))
            yl1 = Packet(make_list(yl.current))
            xl.i += 1
            xs.append(xl1)
            yl.i += 1
            ys.append(yl1)
            continue
        except IndexError:
            if len(xl) < len(yl):
                return True
            elif len(xl) > len(yl):
                return False
            else:
                xs.pop()
                ys.pop()
                continue

dividers = [Packet([[2]]), Packet([[6]])]

with open("input.txt") as f:
    packets = [Packet(eval(l.strip())) for l in f if l and l != "\n"]
packets.extend(dividers)

packets.sort()

i1, i2, = [packets.index(d)+1 for d in dividers]

print(i1*i2)
