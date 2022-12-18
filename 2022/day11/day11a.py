#!/bin/env python3
from collections import defaultdict
from pprint import pprint
import operator
import re


class Monkey(object):
    monkinator = re.compile(r"""
        Monkey[ ]\d+:
        \s+
        Starting[ ]items:[ ](?P<items>[\d, ]+)
        \s+
        Operation:[ ]new[ ]=[ ]old[ ](?P<op>.)[ ](?P<arg>\w+)
        \s+
        Test:[ ]divisible[ ]by[ ](?P<divisible_by>\d+)
        \s+
        If[ ]true:[ ]throw[ ]to[ ]monkey[ ](?P<true_to>\d+)
        \s+
        If[ ]false:[ ]throw[ ]to[ ]monkey[ ](?P<false_to>\d+)
    """, flags=re.X)

    def __init__(self, g):
        self.inspections = 0
        self.items = [int(i) for i in g["items"].split(", ")]
        if g["op"] == "+":
            self.op = operator.add
        elif g["op"] == "*":
            self.op = operator.mul
        if g["arg"] == "old":
            self.arg = "old"
        else:
            self.arg = int(g["arg"])
        self.divisible_by = int(g["divisible_by"])
        self.true_to = int(g["true_to"])
        self.false_to = int(g["false_to"])

    def __repr__(self):
        return f"""Monkey<new = old {self.op} {self.arg}, if mod {self.divisible_by} then {self.true_to} else {self.false_to}, items={self.items}>"""

    def take_turn(self):
        self.inspections += len(self.items)
        dumps = defaultdict(list)
        for item in self.items:
            if self.arg == "old":
                arg = item
            else:
                arg = self.arg
            new_worry = self.op(item, arg) // 3
            if new_worry % self.divisible_by == 0:
                dumps[self.true_to].append(new_worry)
            else:
                dumps[self.false_to].append(new_worry)
        self.items = []
        return dumps


with open("input.txt") as f:
    monkeys = [Monkey(g.groupdict()) for g in Monkey.monkinator.finditer(f.read())]

pprint(monkeys)

for _ in range(20):
    for m in monkeys:
        dumps = m.take_turn()
        for k, v in dumps.items():
            monkeys[k].items.extend(v)

monkeys.sort(key=lambda m: m.inspections)
print(monkeys[-1].inspections * monkeys[-2].inspections)
