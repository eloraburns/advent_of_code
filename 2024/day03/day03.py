import re

with open("test.txt") as f:
    testa = f.read()
with open("testb.txt") as f:
    testb = f.read()
with open("input.txt") as f:
    program = f.read()

def part_a(p):
    mul_re = re.compile(r'mul\((\d{1,3}),(\d{1,3})\)')

    print("PART A")
    print(sum(int(a) * int(b) for (a, b) in mul_re.findall(p)))

def part_b(p):
    mul_re = re.compile(r"mul\((\d{1,3}),(\d{1,3})\)|(do)\(\)|(don)'t\(\)")

    print("PART B")
    enable = 1
    acc = 0
    for (a, b, do, don) in mul_re.findall(p):
        if do:
            enable = 1
        elif don:
            enable = 0
        else:
            acc += int(a) * int(b) * enable
    print(acc)

print("TEST")
part_a(testa)
part_b(testb)

print("\nACTUAL")
part_a(program)
part_b(program)
