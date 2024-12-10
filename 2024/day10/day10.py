import sys

class BoundlessList:
    def __init__(self, iterable, default=None):
        self.list = list(iterable)
        self.default = default

    def __getitem__(self, idx):
        if 0 <= idx and idx < len(self.list):
            return self.list[idx]
        else:
            return self.default

    def __len__(self):
        return len(self.list)

    def __repr__(self):
        return repr(self.list)

def parse(raw):
    return BoundlessList((
        BoundlessList((int(c) for c in row), -1)
        for row in raw.split("\n")),
        BoundlessList([], -1)
    )

def find_trailheads(topo):
    return [
        (x, y)
        for y in range(len(topo))
        for x in range(len(topo[0]))
        if topo[y][x] == 0
    ]

def part_a(raw):
    topo = parse(raw)
    #print(topo)
    trailheads = find_trailheads(topo)
    acc = 0
    for head in trailheads:
        to_explore = set([head])
        #print(0, to_explore)
        for height in range(1, 10):
            to_explore = set([
                (x, y)
                for (nx, ny) in to_explore
                for (x, y) in [
                    (nx+1, ny),
                    (nx-1, ny),
                    (nx, ny+1),
                    (nx, ny-1)
                ]
                if topo[y][x] == height
            ])
            #print(height, to_explore)
        acc += len(to_explore)
    return acc

def take_step_and_return_paths(coord, topo):
    (nx, ny) = coord
    height = topo[ny][nx]
    if height == 9:
        return 1
    return sum(
        take_step_and_return_paths((x, y), topo)
        for (x, y) in [
            (nx+1, ny),
            (nx-1, ny),
            (nx, ny+1),
            (nx, ny-1)
        ]
        if topo[y][x] == height+1
    )

def part_b(raw):
    topo = parse(raw)
    trailheads = find_trailheads(topo)
    return sum(take_step_and_return_paths(head, topo) for head in trailheads)

with open("input.txt") as f:
    input_txt = f.read().strip()

with open("testa.txt") as f:
    testa = f.read().strip()

print("TEST PART A (expect 36)")
print(part_a(testa))
print("TEST PART B (expect 81)")
print(part_b(testa))


print()
print("PART A")
print(part_a(input_txt))

print("PART B")
print(part_b(input_txt))
