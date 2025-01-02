with open("testa.txt") as f:
    testa = f.read()

with open("testa_expect.txt") as f:
    testa_expect = f.read()

with open("input.txt") as f:
    input_txt = f.read()

# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+

#     +---+---+
#     | ^ | A |
# +---+---+---+
# | < | v | > |
# +---+---+---+

numeric_coords = {
    "7": (1, 1), "8": (2, 1), "9": (3, 1),
    "4": (1, 2), "5": (2, 2), "6": (3, 2),
    "1": (1, 3), "2": (2, 3), "3": (3, 3),
                 "0": (2, 4), "A": (3, 4)
 }

def encode_numeric(output):
    cx, cy = numeric_coords["A"]
    required_inputs = []
    for char in output:
        nx, ny = numeric_coords[char]
        if ny == 4 and cx == 1:
            required_inputs.append(">" * (ny - cy))
            required_inputs.append("v" * (nx - cx))
        elif nx == 1 and cy == 4:
            required_inputs.append("^" * (cy - ny))
            required_inputs.append("<" * (cx - nx))
        else:
            if cx > nx:
                required_inputs.append("<" * (cx - nx))
            if cy < ny:
                required_inputs.append("v" * (ny - cy))
            if cy > ny:
                required_inputs.append("^" * (cy - ny))
            if cx < nx:
                required_inputs.append(">" * (nx - cx))
        required_inputs.append("A")
        cx, cy = nx, ny
    return "".join(required_inputs)

direction_coords = {
                 "^": (2, 1), "A": (3, 1),
    "<": (1, 2), "v": (2, 2), ">": (3, 2)
}
direction_map = {
    ("^", "^"): "",
    ("^", "A"): ">",
    ("^", "<"): "v<",
    ("^", "v"): "v",
    ("^", ">"): "v>",

    ("A", "^"): "<",
    ("A", "A"): "",
    ("A", "<"): "v<<",
    ("A", "v"): "<v",
    ("A", ">"): "v",

    ("<", "^"): ">^",
    ("<", "A"): ">>^",
    ("<", "<"): "",
    ("<", "v"): ">",
    ("<", ">"): ">>",

    ("v", "^"): "^",
    ("v", "A"): "^>",
    ("v", "<"): "<",
    ("v", "v"): "",
    ("v", ">"): ">",

    (">", "^"): "<^",
    (">", "A"): "^",
    (">", "<"): "<<",
    (">", "v"): "<",
    (">", ">"): "",
}

def encode_directional(output):
    return "".join(
        direction_map[change] + "A"
        for change in zip("A"+output, output)
    )

def printpads(pad3, pad2, pad1, output):
    fpad3 = pad3
    print(f"{fpad3=}")
    fpad2 = ""
    ix = 0
    for c in pad2:
        nix = pad3.index("A", ix)
        fpad2 += " " * (nix - ix)
        ix = nix + 1
        fpad2 += c
    print(f"{fpad2=}")
    fpad1 = ""
    ix = 0
    for c in pad1:
        nix = fpad2.index("A", ix)
        fpad1 += " " * (nix - ix)
        ix = nix + 1
        fpad1 += c
    print(f"{fpad1=}")
    foutp = ""
    ix = 0
    for c in output:
        nix = fpad1.index("A", ix)
        foutp += " " * (nix - ix)
        ix = nix + 1
        foutp += c
    print(f"{foutp=}")


def solve1_one(output, progress=False):
    if progress: print(f"Encoding {output!r}")
    pad1 = encode_numeric(output)
    pad2 = encode_directional(pad1)
    pad3 = encode_directional(pad2)
    num = int(output[:3])
    len_pad3 = len(pad3)
    if progress: printpads(pad3, pad2, pad1, output)
    if progress: print(f"  {num=} {len_pad3=} => {num * len_pad3=}")
    return int(output[:3]) * len(pad3)


def solve1(raw, progress=False):
    return sum(solve1_one(code, progress=progress) for code in raw.strip().split("\n"))

print("PRETEST 029A")
print("""
    029A
    <A^A>^^AvvvA
    v<<A>>^A<A>AvA<^AA>A<vAAA>^A
    <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A
""")
print(solve1_one("029A", progress=True))

print()
print("TEST 1A (expect 126384)")
print("Also expecting 68 * 29  ||  60 * 980  ||  68 * 179  ||  64 * 456  ||  64 * 379")
print(solve1(testa, progress=True))

#Encoding '           3                          7          9                 A'
#    pad1='       ^   A       ^^        <<       A     >>   A        vvv      A'
#    pad2='   <   A > A   <   AA  v <   AA >>  ^ A  v  AA ^ A  v <   AAA >  ^ A'
#    pad3='v<<A>>^AvA^Av<<A>>^AAv<A<A>>^AAvAA^<A>Av<A>^AA<A>Av<A<A>>^AAAvA^<A>A'

#                     3                      7          9                 A
#                 ^   A         <<      ^^   A     >>   A        vvv      A
#             <   A > A  v <<   AA >  ^ AA > A  v  AA ^ A   < v  AAA >  ^ A
# e.g.     <v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A
# len_pad3 = 68 BUT SHOULD BE 64


# Encoding '379A'
#   pad1='^A^^<<A>>A>>>A'
#   pad2='<A>A<AAv<AA>>^AvAA^AvAAA^A'
#   pad3='v<<A>>^AvA^Av<<A>>^AAv<A<A>>^AAvAA^<A>Av<A>^AA<A>Av<A>^AAA<A>A'
#                     3                          7          9           A
#                 ^   A       ^^        <<       A     >>   A     >>>   A
#             <   A > A   <   AA  v <   AA >>  ^ A  v  AA ^ A  v  AAA ^ A
#          v<<A>>^AvA^Av<<A>>^AAv<A<A>>^AAvAA^<A>Av<A>^AA<A>Av<A>^AAA<A>A

print("SOLVE 1")
# 145240 is too high
print(solve1(input_txt, progress=True))
#X Encoding '140A'
#X   pad1='^<<A^A>>vA>A'
#X   pad2='<Av<AA>>^A<A>AvAA<A>^AvA^A'
#X   pad3='v<<A>>^Av<A<A>>^AAvAA^<A>Av<<A>>^AvA^Av<A>^AAv<<A>>^AvA^<A>Av<A>^A<A>A'
#X   num=140 len_pad3=70 => num * len_pad3=9800
#X Encoding '180A'
#X   pad1='^<<A>^^AvvvA>A'
#X   pad2='<Av<AA>>^AvA^<AA>Av<AAA>^AvA^A'
#X   pad3='v<<A>>^Av<A<A>>^AAvAA^<A>Av<A>^A<Av<A>>^AAvA^Av<A<A>>^AAAvA^<A>Av<A>^A<A>A'
#X   num=180 len_pad3=74 => num * len_pad3=13320
#X Encoding '176A'
#X   pad1='^<<A^^A>>vAvvA'
#X   pad2='<Av<AA>>^A<AA>AvAA<A>^Av<AA>^A'
#X   pad3='v<<A>>^Av<A<A>>^AAvAA^<A>Av<<A>>^AAvA^Av<A>^AAv<<A>>^AvA^<A>Av<A<A>>^AAvA^<A>A'
#X   num=176 len_pad3=78 => num * len_pad3=13728
#X Encoding '805A'
#X   pad1='<^^^AvvvA^^A>vvA'
#X   pad2='v<<A>^AAA>Av<AAA>^A<AA>AvA<AA>^A'
#X   pad3='v<A<AA>>^AvA^<A>AAAvA^Av<A<A>>^AAAvA^<A>Av<<A>>^AAvA^Av<A>^Av<<A>>^AAvA^<A>A'
#X   num=805 len_pad3=76 => num * len_pad3=61180
#X Encoding '638A'
#X   pad1='^^AvA<^^A>vvvA'
#X   pad2='<AA>Av<A>^Av<<A>^AA>AvA<AAA>^A'
#X   pad3='v<<A>>^AAvA^Av<A<A>>^AvA^<A>Av<A<AA>>^AvA^<A>AAvA^Av<A>^Av<<A>>^AAAvA^<A>A'
#X   num=638 len_pad3=74 => num * len_pad3=47212
#X 145240
# 
# 138764 is just right!
# I did get some hints from the AoC subreddit though. Pretty sure I could have
# brute-forced it or eventually figured out the heuristic, but it's … so
# _weird_. Neat to wrap one's head around, but weird.


# The hint for part 2 is to do memoization, because there's a lot of repeated
# moves from one end to the other. And apparently each _layer_ has a consistent
# move count when you have to go from button I to button J. Still, trying to
# figure out how to do that…with the extra hint of using a recursive solution.

def solve_one_recursive(output, num_robots=2):
    pad1 = encode_numeric(output)
    print(f"  output={output}")
    print(f"  pad1  ={pad1}")
    length = sum(
        recursive_numpad(from_to, 0, num_robots)
        for from_to in zip("A"+pad1, pad1)
    )
    print(f"   {int(output[:3])=} * {length=}")
    return int(output[:3]) * length

memoize_dictionary = {}
def memoize(f):
    global memoize_dictionary
    d = memoize_dictionary
    def memoized(*args):
        if args not in d:
            d[args] = f(*args)
        return d[args]
    return memoized

@memoize
def recursive_numpad(from_to, layer, of_layers):
    moves = direction_map[
        (from_to[0], from_to[1])
    ] + "A"
    if layer+1 == of_layers:
        print(f"  recursive {from_to=} {layer=} {of_layers=} {moves=}")
        return len(moves)
    else:
        return sum(
            recursive_numpad(from_to, layer+1, of_layers)
            for from_to in zip("A"+moves, moves)
        )

print("Testing recursive memoized")
print("Code 379A, expect score 24256")
print(f"{solve_one_recursive('379A', num_robots=2)=}")
print()
print(f"{sorted(memoize_dictionary.items())=}")

def solve2(raw, num_robots=2):
    return sum(solve_one_recursive(code, num_robots) for code in raw.strip().split("\n"))

print("Test one via method 2 (expect 126384)")
print(solve2(testa, num_robots=2))

print("Solve one via method 2 (expect 138764)")
print(solve2(input_txt, num_robots=2))

print("Solve 2")
print(solve2(input_txt, num_robots=25))
# 192423806629170 is too high
# 169137886514152
