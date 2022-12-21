#!/bin/env python3

import operator

class Human(Exception): pass

class Monkey(object):
    OPS = {
        "+": operator.add,
        "-": operator.sub,
        "*": operator.mul,
        "/": operator.floordiv,
    }

    REVOP = {
        operator.add: operator.sub,
        operator.sub: operator.add,
        operator.mul: operator.floordiv,
        operator.floordiv: operator.mul,
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
        if self.name == "humn":
            raise Human()
        elif self.name == "root":
            try:
                a = ctx[self.a].eval(ctx)
            except Human:
                self.a, self.b = self.b, self.a
                a = ctx[self.a].eval(ctx)
            return ctx[self.b].eval_humn(ctx, a)
        elif self.value is not None:
            return self.value
        else:
            return self.op(ctx[self.a].eval(ctx), ctx[self.b].eval(ctx))

    def eval_humn(self, ctx, n):
        if self.name == "humn":
            raise Exception("You messed up")
        elif self.value is not None:
            return self.value
        elif self.a == "humn":
            # n = humn OP b
            # n REVOP b = humn
            # n = humn + b => n - b = humn
            # n = humn - b => n + b = humn
            # n = humn * b => n / b = humn
            # n = humn / b => n * b = humn
            return self.REVOP[self.op](n, ctx[self.b].eval(ctx))
        elif self.b == "humn":
            a = ctx[self.a].eval(ctx)
            if self.op is operator.add:
                # n = a + humn => n - a = humn
                return n - a
            elif self.op is operator.sub:
                # n = a - humn => a - n = humn
                return a - n
            elif self.op is operator.mul:
                # n = a * humn => n / a = humn
                return n // a
            elif self.op is operator.floordiv:
                # n = a / humn => a / n = humn
                return a // n
        else:
            try:
                a = ctx[self.a].eval(ctx)
            except Human:
                b = ctx[self.b].eval(ctx)
                new_n = self.REVOP[self.op](n, b)
                return ctx[self.a].eval_humn(ctx, new_n)
            else:
                if self.op is operator.add:
                    new_n = n - a
                elif self.op is operator.sub:
                    new_n = a - n
                elif self.op is operator.mul:
                    new_n = n // a
                elif self.op is operator.floordiv:
                    new_n = a // n
                else:
                    raise Exception("No, really")
                return ctx[self.b].eval_humn(ctx, new_n)


with open("input.txt") as f:
    monkeys = {monkey.name: monkey for monkey in (Monkey(l) for l in f)}

print(monkeys["root"].eval(monkeys))
