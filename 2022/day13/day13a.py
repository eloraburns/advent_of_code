#!/bin/env python3
from itertools import zip_longest
from pprint import pprint

with open("input.txt") as f:
    pairs = [[eval(y[0]), eval(y[1])] for y in (x.split("\n") for x in f.read().split("\n\n"))]

acc = 0

def make_list(i):
    if isinstance(i, int):
        return [i]
    else:
        return i

# d = 0
# sentinel = object()
# 
# def compare(x, y):
#     global d
#     d += 1
#     print(f"{d},", end="")
#     if x is sentinel:
#         return True
#     elif y is sentinel:
#         return False
#     for xa, ya in zip_longest(x, y, fillvalue=sentinel):
#         if isinstance(xa, int) and isinstance(ya, int):
#             if xa < ya:
#                 return True
#             elif xa > ya:
#                 return False
# 
#         r = compare(make_list(xa), make_list(ya))
#         if r is True or r is False:
#             return r
# 
# for (i, [x, y]) in enumerate(pairs, start=1):
#     d = 0
#     if compare(x, y):
#         acc += i

class Packet(object):
    def __init__(self, p):
        self.p = p
        self.i = 0

    @property
    def current(self):
        return self.p[self.i]

    def __len__(self):
        return len(self.p)

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

for (i, [x, y]) in enumerate(pairs, start=1):
    pprint((i, [x, y]))
    if compare(Packet(x), Packet(y)):
        print(f"ADD {i}")
        acc += i
    else:
        print("Nope")
    

# 150 is too low
print(acc)
