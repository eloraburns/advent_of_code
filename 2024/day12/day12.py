print('=======')

def parse(raw):
    # print repr(raw)
    return {
        (x, y): c
        for (y, l) in enumerate(raw.strip().split('\n'))
        for (x, c) in enumerate(l)
    }

def flood_fill(m, x, y):
    in_region = {(x, y)}
    seen = set(in_region)
    to_check = set(in_region)
    fence = 0
    while to_check and (here := to_check.pop()):
        # print(f"  > {here=}, {seen=}, {to_check=}")
        hereplant = m[here]
        (nx, ny) = here
        for looking in [(nx-1,ny), (nx+1,ny), (nx,ny-1), (nx,ny+1)]:
            # print(f"    {looking=}")
            if m.get(looking) == hereplant:
                if looking not in seen:
                    to_check.add(looking)
                seen.add(looking)
            else:
                fence += 1
        # print(f"  < {fence=}, {seen=}, {to_check=}")
    return (seen, fence)

def part_a(m):
    total_cost = 0
    seen = set()
    for (x, y) in m:
        if (x, y) in seen: continue
        (area_set, perimeter) = flood_fill(m, x, y)
        # print(f"Found region {perimeter=}, {area_set=})")
        total_cost += len(area_set) * perimeter
        seen.update(area_set)
    return total_cost

def flood_fill_b(m, x, y):
    in_region = {(x, y)}
    seen = set(in_region)
    to_check = set(in_region)
    fence = set()
    while to_check and (here := to_check.pop()):
        # print(f"  > {here=}, {seen=}, {to_check=}")
        hereplant = m[here]
        (nx, ny) = here
        for (looking, direction) in [
            ((nx-1,ny), "L"),
            ((nx+1,ny), "R"),
            ((nx,ny-1), "U"),
            ((nx,ny+1), "D"),
        ]:
            # print(f"    {looking=}")
            if m.get(looking) == hereplant:
                if looking not in seen:
                    to_check.add(looking)
                seen.add(looking)
            else:
                fence.add((here, direction))
        # print(f"  < {fence=}, {seen=}, {to_check=}")
    side_count = 0
    # print(f"  Counting sides of {sorted(fence)}")
    while fence and (popped := fence.pop()):
        ((fx, fy), direction) = popped
        # print(f"    {popped=}", end="")
        if direction in "UD":
            nfx = fx+1
            nfy = fy
            while (maybe_fence := ((nfx, nfy), direction)) in fence:
                # print(f" {maybe_fence=}", end="")
                fence.remove(maybe_fence)
                nfx += 1
            nfx = fx-1
            while (maybe_fence := ((nfx, nfy), direction)) in fence:
                fence.remove(maybe_fence)
                # print(f" {maybe_fence=}", end="")
                nfx -= 1
        elif direction in "LR":
            nfx = fx
            nfy = fy+1
            while (maybe_fence := ((nfx, nfy), direction)) in fence:
                fence.remove(maybe_fence)
                # print(f" {maybe_fence=}", end="")
                nfy += 1
            nfy = fy-1
            while (maybe_fence := ((nfx, nfy), direction)) in fence:
                fence.remove(maybe_fence)
                # print(f" {maybe_fence=}", end="")
                nfy -= 1
        else:
            raise "wtf?"
        side_count += 1
        # print(f"\n      {side_count=}")
    # print(f"  = {seen=}, {side_count=}")
    return (seen, side_count)


def part_b(m):
    total_cost = 0
    seen = set()
    for (x, y) in m:
        if (x, y) in seen: continue
        (area_set, perimeter) = flood_fill_b(m, x, y)
        # print(f"Found region {perimeter=}, {area_set=})")
        total_cost += len(area_set) * perimeter
        # print(f" - {total_cost=}")
        seen.update(area_set)
    # print(f" ! {total_cost=}")
    return total_cost
        
tests = [
    ("a", 4),
    ("aa", 12),
    ("aaa", 24),
    ("aa\naa", 32),
    (
'''AAAA
BBCD
BBCC
EEEC
''', 140),
    (
'''OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
''', 772),
    (
'''RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
''', 1930)
]

for (m, expected) in tests:
    print(f">> TEST EXPECTS {expected}")
    print(m)
    print('<< GOT {}'.format(expected, part_a(parse(m))))
    print()

with open("input.txt") as f:
    input_txt = f.read()

print("PART A")
print(part_a(parse(input_txt)))
print(); print()


tests_b = [
    ("a", 4),
    ("aa", 8),
    ("aaa", 12),
    ("aa\nbb", 16),
    (
'''AAAA
BBCD
BBCC
EEEC''', 80),
    (
'''EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
''', 236),
    (
'''AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
''', 368),
    (
'''RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
''', 1206)
]

for (m, expected) in tests_b:
    print(f">> TEST EXPECTS {expected}")
    print(m)
    print(f"<< GOT {part_b(parse(m))}")
    print()

print("PART B - 1010898 is too high")
print("  …and therefore so is 1012230?!?!")
print("  …873584 will be just right")
print(part_b(parse(input_txt)))
