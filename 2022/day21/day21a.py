#!/bin/env python3

import operator

class Monkey(object):
    OPS = {
        "+": operator.add,
        "-": operator.sub,
        "*": operator.mul,
        "/": operator.floordiv,
    }

    def __init__(self, l):
        [name, job] = l.strip().split(": ")
        self.name = name
        try:
            [a, op, b] = job.split(" ")
            self.a = a
            self.op = self.OPS[op]
            self.b = b
            self.value = None
        except ValueError:
            self.value = int(job)

    def eval(self, ctx):
        if self.value is not None:
            return self.value
        else:
            return self.op(ctx[self.a].eval(ctx), ctx[self.b].eval(ctx))


with open("input.txt") as f:
    monkeys = {monkey.name: monkey for monkey in (Monkey(l) for l in f)}

print(monkeys["root"].eval(monkeys))
