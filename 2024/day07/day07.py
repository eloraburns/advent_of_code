from functools import reduce
import operator
import sys

def parse(raw_input):
    equations = []
    for l in raw_input.strip().split("\n"):
        [equals, nums] = l.split(": ")
        equations.append((int(equals), [int(n) for n in nums.split(" ")]))
    return equations

def part_a(equations):
    acc = 0
    for (equals, nums) in equations:
        for perm in range(2**len(nums)-1):
            ops = (
                operator.mul if perm & 2**i else operator.add
                for i in range(len(nums)-1)
               )
            total = reduce(lambda a, b: next(ops)(a, b), nums)
            if total == equals:
                print(f"{total=} {equals=} when {nums=} and {perm=}")
                acc += equals
                break
    return acc

OPS = (operator.add, operator.mul, lambda a, b: int(f"{a}{b}"))

def part_b(equations):
    acc = 0
    for (equals, nums) in equations:
        for perm in range(3**len(nums)-1):
            ops = (
                OPS[(perm//(3**i)) % 3]
                for i in range(len(nums)-1)
               )
            total = reduce(lambda a, b: next(ops)(a, b), nums)
            if total == equals:
                print(f"{total=} {equals=} when {nums=} and {perm=}")
                acc += equals
                break
    return acc

with open("input.txt") as f:
    input_txt = parse(f.read())

with open("testa.txt") as f:
    testa = parse(f.read())

print("TEST PART A (expect 3749)")
print(part_a(testa))
print("TEST PART B (expect 11387)")
print(part_b(testa))


print("PART A")
print(part_a(input_txt))

print("PART B")
print(part_b(input_txt))
