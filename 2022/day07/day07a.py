#!/bin/env python3

class Directory(object):
    def __init__(self, name, parent=None):
        self.name = name
        self.parent = parent
        self.size = 0
        self.subs = {}

    def sub(self, name):
        s = Directory(name, self)
        self.subs[name] = s
        return s

    def parent(self):
        return self.parent

    def accumulate_sub_size(self):
        for s in self.subs.values():
            s.accumulate_sub_size()
            self.size += s.size

    def walk(self, fn):
        yield fn(self)
        for s in self.subs.values():
            yield from s.walk(fn)

with open("input.txt") as f:
    assert next(f) == "$ cd /\n"
    root = current = Directory("/")
    for l in f:
        l = l.strip()
        if l == "$ cd ..":
            current = current.parent
        elif l.startswith("$ cd "):
            current = current.sub(l[5:])
        elif l.startswith("$ ls"):
            pass
        elif l.startswith("dir "):
            pass
        else:
            [size, name] = l.split(" ")
            current.size += int(size)

root.accumulate_sub_size()

part_a = sum(
    filter(
        lambda x: x <= 100000,
        root.walk(lambda x: x.size)
    )
)
print(f"Part a: {part_a}")

total = 70000000
needed = 30000000
free = total - root.size
min_to_free = needed - free
part_b = sorted(
    filter(
        lambda x: x >= min_to_free,
        root.walk(lambda x: x.size)
    )
)[0]
print(f"Part b: {part_b}")
