#!/bin/env python3

from collections import defaultdict

dirs = defaultdict(lambda: 0)

class PeekableIterator(object):
    no_item = object()

    def __init__(self, iterator):
        self.iterator = iterator
        self.next = self.no_item

    def __next__(self):
        if self.next is not self.no_item:
            the_next = self.next
            self.next = self.no_item
            return the_next
        else:
            return next(self.iterator)

    def peek(self):
        if self.next is self.no_item:
            self.next = next(self.iterator)
        return self.next


def construct(f, current, dirs):
    subs = []
    while True:
        if f.peek() == "$ cd ..\n":
            return
        elif f.peek().startswith("$ cd"):
            next(f)
            sub = f"{current}/{l[4:-1]}"
            construct(f, sub, dirs)
            dirs[current] += dirs[sub]
        elif f.peek() == "$ dir\n":
            next(f)
            while not f.peek().startswith("$"):
                if f.peek().startswith("dir "):
                    next(f) # ignore directories when listed
                else:
                    [sz, nm] = next(f).strip().split(" ")
                    dirs[current] += int(sz)
            

with open("input.txt") as f:
    assert next(f) == "$ cd /\n"
    construct(PeekableIterator(f), "/", dirs)
