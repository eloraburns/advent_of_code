from collections import defaultdict

with open("testa.txt") as f:
    testa = f.read()

with open("testb.txt") as f:
    testb = f.read()

with open("input.txt") as f:
    input_txt = f.read()

def parsea(raw):
    (rega, regb, regc, empty, prog) = raw.strip().split("\n")

    return {
        "a": int(rega.split(": ")[1]),
        "b": int(regb.split(": ")[1]),
        "c": int(regc.split(": ")[1]),
        "p": [int(i) for i in prog.split(": ")[1].split(",")]
    }

OP_ADV = 0
OP_BXL = 1
OP_BST = 2
OP_JNZ = 3
OP_BXC = 4
OP_OUT = 5
OP_BDV = 6
OP_CDV = 7

ops = {
    OP_ADV: "ADV",
    OP_BXL: "BXL",
    OP_BST: "BST",
    OP_JNZ: "JNZ",
    OP_BXC: "BXC",
    OP_OUT: "OUT",
    OP_BDV: "BDV",
    OP_CDV: "CDV",
}
combos = {OP_ADV, OP_BST, OP_OUT, OP_BDV, OP_CDV}

def decompile(opcode, operand):
    if opcode in combos:
        if   operand == 4: operand = "[a]"
        elif operand == 5: operand = "[b]"
        elif operand == 6: operand = "[c]"
        return f"{ops[opcode]} {operand}"
    else:
        return f"{ops[opcode]} {operand}"

def run(machine, debug=False):
    a = machine["a"]
    b = machine["b"]
    c = machine["c"]
    p = machine["p"]
    def combo_op(val):
        if val < 4: return val
        if val == 4: return a
        if val == 5: return b
        if val == 6: return c
        if val == 7: 1/0
    pc = 0
    out = []
    if debug: print(f"{p=}")
    while pc < len(p):
        if debug:
            print(f"{a=} {b=} {c=} {pc=} {out=}")
            print(f"  {decompile(p[pc], p[pc+1])}")
        if p[pc] == OP_ADV:
            a >>= combo_op(p[pc+1])
            pc += 2
        elif p[pc] == OP_BXL:
            b ^= p[pc+1]
            pc += 2
        elif p[pc] == OP_BST:
            b = combo_op(p[pc+1]) & 7
            pc += 2
        elif p[pc] == OP_JNZ:
            if a == 0:
                pc += 2
            else:
                pc = p[pc+1]
        elif p[pc] == OP_BXC:
            b = b ^ c
            pc += 2
        elif p[pc] == OP_OUT:
            out.append(combo_op(p[pc+1]) & 7)
            pc += 2
        elif p[pc] == OP_BDV:
            b = a >> combo_op(p[pc+1])
            pc += 2
        elif p[pc] == OP_CDV:
            c = a >> combo_op(p[pc+1])
            pc += 2

    return {"a": a, "b": b, "c": c, "out": out}

def run_generator(machine, debug=False):
    a = machine["a"]
    b = machine["b"]
    c = machine["c"]
    p = machine["p"]
    def combo_op(val):
        if val < 4: return val
        if val == 4: return a
        if val == 5: return b
        if val == 6: return c
        if val == 7: 1/0
    pc = 0
    if debug: print(f"{p=}")
    while pc < len(p):
        if debug:
            print(f"{a=} {b=} {c=} {pc=} {out=}")
            print(f"  {decompile(p[pc], p[pc+1])}")
        if p[pc] == OP_ADV:
            a >>= combo_op(p[pc+1])
            pc += 2
        elif p[pc] == OP_BXL:
            b ^= p[pc+1]
            pc += 2
        elif p[pc] == OP_BST:
            b = combo_op(p[pc+1]) & 7
            pc += 2
        elif p[pc] == OP_JNZ:
            if a == 0:
                pc += 2
            else:
                pc = p[pc+1]
        elif p[pc] == OP_BXC:
            b = b ^ c
            pc += 2
        elif p[pc] == OP_OUT:
            yield combo_op(p[pc+1]) & 7
            pc += 2
        elif p[pc] == OP_BDV:
            b = a >> combo_op(p[pc+1])
            pc += 2
        elif p[pc] == OP_CDV:
            c = a >> combo_op(p[pc+1])
            pc += 2

def tests():

    in_state = {"a": 5, "b": 3, "c": 1, "p": [0, 2]}
    actual = run(in_state)
    if actual["a"] != 1:
        raise Exception("Test failure")

    in_state = {"a": 5, "b": 3, "c": 1, "p": [0, 6]}
    actual = run(in_state)
    if actual["a"] != 2:
        raise Exception("Test failure")

    in_state = {"a": 5, "b": 3, "c": 1, "p": [1, 1]}
    actual = run(in_state)
    if actual["b"] != 2:
        raise Exception("Test failure")

    in_state = {"a": 5, "b": 3, "c": 1, "p": [1, 7]}
    actual = run(in_state)
    if actual["b"] != 4:
        raise Exception("Test failure")

    in_state = {"a": 5, "b": 3, "c": 1, "p": [2, 3]}
    actual = run(in_state)
    if actual["b"] != 3:
        raise Exception("Test failure")

    in_state = {"a": 5, "b": 33, "c": 1, "p": [2, 5]}
    actual = run(in_state)
    if actual["b"] != 1:
        raise Exception("Test failure")

    print("tests ok!")

tests()

print("TEST 1A (expect '4,6,3,5,6,3,5,2,1,0')")
print(",".join(str(i) for i in run(parsea(testa))["out"]))
print("INPUT 1")
print(",".join(str(i) for i in run(parsea(input_txt))["out"]))



def solveb(raw):
    in_state = parsea(raw)
    a = -1
    p = in_state["p"]
    out = []
    while out != p:
        a += 1
        if a % 10 == 0:
            print(f"{a:8}", end="\r")
        in_state["a"] = a
        out = run(in_state)["out"]
        #if a == 117440:
        #    run(in_state, debug=True)
        #    print()
        #    print(f"{out=} {p=}")
        #    break
    print()
    return a

p = parsea(input_txt)["p"]
print("decompile input.txt")
for i in range(0, len(p), 2):
    print(decompile(p[i], p[i+1]))


# 0b000
#   0b000 ^ 0b001          = 0b001
#   0b001 ^ a >> 1 ^ 0b100 = 0b101 ^ a >> 1
#   a = 0b0000 => 5
#   a = 0b1000 => 1
# 0b001
#   0b001 ^ 0b001          = 0b000
#   0b000 ^ a >> 0 ^ 0b100 = 0b101
#   a = 0b001 => 5
# 0b010
#   0b010 ^ 0b001          = 0b011
#   0b011 ^ a >> 3 ^ 0b100 = 0b111 ^ a >> 3
#   0bxxx.....010
#   a = 0b111 ^ xxx
# 0b011
#   0b011 ^ 0b001
#   0b010 ^ a >> 2 & 0b100 = 0b110 ^ a >> 2
#   0bxx011
#   a = 0b110 & xx0
# 0b100
#   0b100 ^ 0b001
#   0b101 ^ a >> 5 ^ 0b100 = 0b001 ^ a >> 5
#   0bxxx.............................100
#   a = 0b001 & xxx
# 0b101
#   0b101 ^ 0b001
#   0b100 ^ a >> 4 ^ 0b100 = a >> 4
#   0bxxx.............101
#   a = xxx
# 0b110
#   0b110 ^ 0b001
#   0b111 ^ a >> 7 ^ 0b100 = 0b011 ^ a >> 7
#   0bxxx.............................................................................................................................110
#   a = 0b011 ^ xxx
# 0b111
#   0b111 ^ 0b001
#   0b110 ^ a >> 6 ^ 0b100 = 0b010 ^ a >> 6
#   0bxxx.............................................................111
#   a = 0b010 ^ xxx

xors = [
    # ( opcode, xor_value, shift )
    #(0b000, 0b101, 1),
    #(0b001, 0b100, 0),
    (0b010, 0b111, 3),
    #(0b011, 0b110, 2),
    (0b100, 0b001, 5),
    (0b101, 0b000, 4),
    (0b110, 0b011, 7),
    (0b111, 0b010, 6),
]

ops_map = defaultdict(list)
for output_value in range(8):
    for (opcode, xor_value, shift) in xors:
        mask = (0b111 << shift) | 0b111
        a_value = ((xor_value ^ output_value) << shift) | opcode
        ops_map[output_value].append((a_value, mask))
# These are special-cased as the "opcode" and stuff that gets xor'd overlaps.
# And there are only 6 of them.
ops_map[1].append((0b1000 , 0b1111  ))
ops_map[5].append((0b0000 , 0b1111  ))
ops_map[5].append((0b001  , 0b111   ))
ops_map[0].append((0b11011, 0b11111 ))
ops_map[2].append((0b10011, 0b11111 ))
ops_map[4].append((0b01011, 0b11111 ))
ops_map[6].append((0b00011, 0b11111 ))
for k, v in ops_map.items():
    ops_map[k] = sorted(v)
print(ops_map)

prog = parsea(input_txt)["p"]

def test_ops_map():
    for out_val in ops_map.keys():
        for (value, mask) in ops_map[out_val]:
            op = value & 0b111
            actual = run({"a": value, "b": 0, "c": 0, "p": prog})["out"]
            if actual and actual[0] == out_val:
                print(f"PASS: {out_val=} op=0b{op:03b} a={value:b}")
            else:
                print(f"FAIL: {out_val=} op=0b{op:03b} for a=0b{value:b} but got {actual=} instead")

test_ops_map()

def find_smallest_a(digits=1, a_so_far=0):
    pad = '.'*digits
    print(f"{pad} find_smallest_a({digits=}, {a_so_far=}")
    if digits > len(prog): return a_so_far
    a_so_far <<= 3
    expected_out = prog[-digits:]
    print(f"{pad}   {expected_out=}")
    for (new_a_op, a_mask) in ops_map[expected_out[0]]:
        print(f"{pad}   Trying {new_a_op=}")
        if ((a_so_far & a_mask) ^ new_a_op) >> 3 == 0:
            potential_a = a_so_far | new_a_op
            out = run({"a": potential_a, "b": 0, "c": 0, "p": prog})["out"]
            print(f"{pad} * a={potential_a} {out=}")
            if out == expected_out:
                if find_smallest_a(digits + 1, potential_a) is not None:
                    return potential_a
    else:
        return None

print("smallest a?")
print(find_smallest_a())

#............... * a=25295828419909 out=[4, 1, 1, 7, 5, 4, 6, 1, 4, 0, 3, 5, 5, 3, 0]
#................ find_smallest_a(digits=16, a_so_far=25295828419909
#5

print("run machine with a=25295828419909")
print(run({"a": 25295828419909, "b": 0, "c": 0, "p": prog}))
# 25295828419909 is too low (yes, it didn't output the leading 2)
print("run machine with a=25295828419909, expect:")
print(prog)
print(run({"a": 202366627359279, "b": 0, "c": 0, "p": prog})["out"])
# 202366627359279 is too high

# 202366627359274
def find_all_a(p, a_so_far=0, mask_so_far=0, shift=0):
    if not p:
        return [a_so_far]
    solutions = []
    for (new_a_op, a_mask) in ops_map[p[0]]:
        mask_intersect = (a_mask << shift) & mask_so_far
        ops_xor = (new_a_op << shift) ^ a_so_far
        if mask_intersect & ops_xor == 0:
            solutions.extend(find_all_a(
                p[1:],
                (new_a_op << shift) | a_so_far,
                (a_mask << shift) | mask_so_far,
                shift + 3
            ))
    return solutions

all_a = find_all_a(p)
print(f"{len(all_a)=}")
print(f"{min(all_a)=}")

# a & 0b000000111 -> b
# b ^ 0b001       -> b
# a >> [b]        -> c
# b ^ c           -> b
# b ^ 0b100       -> b
# 
# a >> 3    ==> This implies that it's a 48-bit number :(
# 
# 2,4,1,1,7,5,4,6,1,4,0,3,5,5,3,0
# 
# 2 ^ 0b100 -> 6


# 0bxy000 -> a
# 0 -> b
# 1 -> b
# 0bxy0 -> c
# 0bxy1 -> b
# 0bXy1 -> b
# OUT B


# BST [a]    - a & 7     -> b
# BXL 1      - b ^ 1     -> b
# CDV [b]    - a >> [b]  -> c
# BXC 6      - b ^ c     -> b
# BXL 4      - b ^ 4     -> b
# ADV 3      - a / 8     -> a
# OUT [b]    - OUT [b]
# JNZ 0      - if a != 0, start again


#print("TEST 2B (expect '117440')")
#print(solveb(testb))
#print("INPUT 2")
#print(solveb(input_txt))



