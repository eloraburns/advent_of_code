import functools
import sys

class SomeMap:
    def __init__(self, obstacles):
        self.obstacles = obstacles
        self._set_maxes()

    def _set_maxes(self):
        (self.maxx, self.maxy) = functools.reduce(
            lambda one, two: (max(one[0], two[0]), max(one[1], two[1])),
            self.obstacles.keys()
        )
        self.xrange = range(self.maxx+1)
        self.yrange = range(self.maxy+1)

class Guard:
    def __init__(self, x, y, direction):
        self.x = x
        self.y = y
        self.direction = direction

    def next_position(self):
        if self.direction == "^":
            return (self.x, self.y-1)
        elif self.direction == ">":
            return (self.x+1, self.y)
        elif self.direction == "v":
            return (self.x, self.y+1)
        elif self.direction == "<":
            return (self.x-1, self.y)
        else:
            1/0

    def turn(self):
        self.direction = {
            "^": ">",
            ">": "v",
            "v": "<",
            "<": "^"
        }[self.direction]

    def move_to(self, coords):
        (self.x, self.y) = coords

    def copy(self):
        return Guard(self.x, self.y, self.direction)

    def __str__(self):
        return f"Guard({self.x}, {self.y}, '{self.direction}')"

def print_map(m, g, o, s):
    for y in m.yrange:
        l = []
        for x in m.xrange:
            if (x, y) in m.obstacles:
                l.append("#")
            elif (g.x, g.y) == (x, y):
                l.append(g.direction)
            elif o == (x, y):
                l.append("O")
            else:
                ud = (x, y, "^") in s or (x, y, "v") in s
                lr = (x, y, "<") in s or (x, y, ">") in s
                if ud and lr:
                    l.append("+")
                elif ud:
                    l.append("|")
                elif lr:
                    l.append("-")
                else:
                    l.append(".")
        print("".join(l))

def parse(f):
    m = {}
    for (y, l) in enumerate(f.readlines()):
        for (x, c) in enumerate(l):
            if c == "#":
                m[(x, y)] = c
            elif c in "^>v<":
                g = Guard(x, y, c)
    return (SomeMap(m), g)

def part_a(m, guard):
    print(f'GUARD! {guard}')
    seen = set([(guard.x, guard.y)])
    while guard.x in m.xrange and guard.y in m.yrange:
        guard_next = guard.next_position()
        if guard_next in m.obstacles:
            guard.turn()
        else:
            seen.add((guard.x, guard.y))
            guard.move_to(guard_next)
    return len(seen)

def part_b(m, guard):
    #print(f'GUARD! {guard}')
    new_obstacle_positions = [
        (x, y)
        for x in m.xrange
        for y in m.yrange
        if (x, y) not in m.obstacles and not (x == guard.x and y == guard.y)
    ]
    #print(f"OBSTACLES: {m.obstacles}")
    original_guard = guard.copy()
    cycle_count = 0
    #print(f"Checking {len(new_obstacle_positions)} options:\n{new_obstacle_positions}")
    for (i, new_obstacle) in enumerate(new_obstacle_positions):
        #print(f"{new_obstacle} ")
        print(f"{100*i//len(new_obstacle_positions):3}%\r", end="")
        guard = original_guard.copy()
        seen = set([(guard.x, guard.y, guard.direction)])
        is_cycle = 0
        #print(f"{guard.x=} in {m.xrange=} and {guard.y=} in {m.yrange=} and not {is_cycle=}")
        #print()
        #print_map(m, guard, new_obstacle, seen)
        #print()
        while guard.x in m.xrange and guard.y in m.yrange and not is_cycle:
            #if new_obstacle == (3, 6):
            #    print()
            #    print_map(m, guard, new_obstacle, seen)
            #    print()
            guard_next = (guard_x, guard_y) = guard.next_position()
            if (guard_x, guard_y, guard.direction) in seen:
                is_cycle = 1
            elif guard_next in m.obstacles or guard_next == new_obstacle:
                guard.turn()
            else:
                guard.move_to(guard_next)
            seen.add((guard.x, guard.y, guard.direction))
        cycle_count += is_cycle
    print("100%")
    return cycle_count

with open("input.txt") as f:
    input_txt = parse(f)

with open("testa.txt") as f:
    testa = parse(f)

print("TEST PART A (expect 41)")
print(part_a(testa[0], testa[1].copy()))
print("TEST PART B (expect 6)")
print(part_b(testa[0], testa[1].copy()))


print()
print("PART A")
print(part_a(input_txt[0], input_txt[1].copy()))

print("PART B")
print(part_b(input_txt[0], input_txt[1].copy()))
