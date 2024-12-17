STEP_NUMBER = 0
DEBUG_STEPS = []

with open("testa.txt") as f:
    testa = f.read()

with open("testb.txt") as f:
    testb = f.read()

with open("input.txt") as f:
    input_txt = f.read()

def parse(raw):
    (ma, mo) = raw.strip().split("\n\n")
    the_map = {}
    robot = None
    for (y, l) in enumerate(ma.split("\n")):
        for (x, c) in enumerate(l):
            the_map[(x, y)] = c
            if c == "@":
                robot = (x, y)
    moves = mo.replace("\n", "")

    return (the_map, robot, moves)

def debug(s):
    if STEP_NUMBER in DEBUG_STEPS: print(s)

class Robot:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def does_occupy(self, x, y):
        return self.x == x and self.y == y

    def _find_directional_neighbour(self, direction, warehouse):
        if   direction == "<": return warehouse.find_occupant(self.x-1, self.y)
        elif direction == ">": return warehouse.find_occupant(self.x+1, self.y)
        elif direction == "^": return warehouse.find_occupant(self.x, self.y-1)
        elif direction == "v": return warehouse.find_occupant(self.x, self.y+1)

    def can_push(self, direction, warehouse):
        debug(f"Robot can push {direction=}")
        return self._find_directional_neighbour(direction, warehouse).can_push(direction, warehouse)

    def do_push(self, direction, warehouse):
        debug(f" Robot do push {self._find_directional_neighbour(direction, warehouse)}")
        self._find_directional_neighbour(direction, warehouse).do_push(direction, warehouse)
        if   direction == "<": self.x -= 1
        elif direction == ">": self.x += 1
        elif direction == "^": self.y -= 1
        elif direction == "v": self.y += 1

    def str_at(self, x):
        return "@"

class Empty:
    @staticmethod
    def can_push(direction, warehouse):
        debug(f"  Empty can push")
        return True

    @staticmethod
    def do_push(direction, warehouse):
        debug(f"  Empty do push")
        pass
    
    def __repr__(self):
        return "Empty"

    def str_at(self, x):
        return "."

class Wall:
    def __init__(self, x, y):
        self.x = range(x, x+2)
        self.y = y

    def does_occupy(self, x, y):
        return x in self.x and y == self.y

    def can_push(self, direction, m):
        debug(f"  {self} can push")
        return False

    def do_push(self, direction, m):
        raise Exception("Cannot push a wall! Didn't you check 'can_push' first?!?!")

    def gps(self):
        return 0

    def __repr__(self):
        return f"Wall({self.x}, {self.y})"

    def str_at(self, x):
        return "#"

class Box:
    def __init__(self, x, y):
        self.x = range(x, x+2)
        self.y = y

    def does_occupy(self, x, y):
        return x in self.x and y == self.y

    def _get_directional_neighbours(self, direction, warehouse):
        if direction == "<":
            return [warehouse.find_occupant(self.x.start-1, self.y)]
        elif direction == ">":
            return [warehouse.find_occupant(self.x.stop, self.y)]
        elif direction == "^":
            return set([warehouse.find_occupant(self.x.start, self.y-1), warehouse.find_occupant(self.x.start+1, self.y-1)])
        elif direction == "v":
            return set([warehouse.find_occupant(self.x.start, self.y+1), warehouse.find_occupant(self.x.start+1, self.y+1)])
        else:
            raise Exception('wat')

    def can_push(self, direction, warehouse):
        debug(f"  {self} can push")
        directional_neighbours = self._get_directional_neighbours(direction, warehouse)
        return all(n.can_push(direction, warehouse) for n in directional_neighbours)

    def do_push(self, direction, warehouse):
        debug(f"  Box do push {self._get_directional_neighbours(direction, warehouse)}")
        for n in self._get_directional_neighbours(direction, warehouse):
            n.do_push(direction, warehouse)
        if   direction == "<": self.x = range(self.x.start-1, self.x.start+1)
        elif direction == ">": self.x = range(self.x.start+1, self.x.start+3)
        elif direction == "^": self.y -= 1
        elif direction == "v": self.y += 1

    def gps(self):
        return self.x.start + self.y*100

    def __repr__(self):
        return f"Box({self.x}, {self.y})"

    def str_at(self, x):
        if x == self.x.start: return "["
        else: return "]"

class Warehouse:
    robot = None

    def __init__(self, raw_map):
        self.parse(raw_map)

    def parse(self, raw_map):
        m = []
        for (y, l) in enumerate(raw_map.split("\n")):
            for (x, c) in enumerate(l):
                if c == '#':
                    m.append(Wall(x*2, y))
                elif c == 'O':
                    m.append(Box(x*2, y))
                elif c == '@':
                    self.robot = Robot(x*2, y)
        self.map = m

    def find_occupant(self, x, y):
        if self.robot.does_occupy(x, y):
            return self.robot
        for entity in self.map:
            if entity.does_occupy(x, y):
                return entity
        return Empty()

    def __str__(self):
        out = []
        maxx = 0
        for e in self.map:
            if isinstance(e.x, range):
                maxx = max(maxx, e.x.stop-1)
            else:
                maxx = max(maxx, e.x)
        maxy = max(e.y for e in self.map)
        for y in range(maxy+1):
            for x in range(maxx+1):
                out.append(self.find_occupant(x, y).str_at(x))
            out.append("\n")
        return "".join(out)

def parse2(raw):
    (ma, mo) = raw.strip().split("\n\n")
    return (Warehouse(ma), mo.replace("\n", ""))

def print_map(m):
    maxx = max(x for (x, y) in m.keys())
    maxy = max(y for (x, y) in m.keys())
    for y in range(maxy + 1):
        for x in range(maxx + 1):
            print(m[(x, y)], end="")
        print()


def solve1(stuff):
    (the_map, robot, moves) = stuff
    maxx = max(x for (x, y) in the_map.keys())
    maxy = max(y for (x, y) in the_map.keys())
    #print_map(the_map)
    for move in moves:
        (x, y) = robot
        if move == "^":
            while y > 0:
                ny = y - 1
                if the_map[(x, ny)] == '#': break
                elif the_map[(x, ny)] == '.':
                    the_map[(x, ny)] = the_map[(x, y)]
                    the_map[(x, robot[1])] = '.'
                    the_map[(x, robot[1] - 1)] = '@'
                    robot = (x, robot[1] - 1)
                    break
                y = ny
        elif move == "v":
            while y < maxy:
                ny = y + 1
                if the_map[(x, ny)] == '#': break
                elif the_map[(x, ny)] == '.':
                    the_map[(x, ny)] = the_map[(x, y)]
                    the_map[(x, robot[1])] = '.'
                    the_map[(x, robot[1] + 1)] = '@'
                    robot = (x, robot[1] + 1)
                    break
                y = ny
        elif move == ">":
            while x < maxx:
                nx = x + 1
                if the_map[(nx, y)] == '#': break
                elif the_map[(nx, y)] == '.':
                    the_map[(nx, y)] = the_map[(x, y)]
                    the_map[(robot[0], y)] = '.'
                    the_map[(robot[0] + 1, y)] = '@'
                    robot = (robot[0] + 1, y)
                    break
                x = nx
        elif move == "<":
            while x > 0:
                nx = x - 1
                if the_map[(nx, y)] == '#': break
                elif the_map[(nx, y)] == '.':
                    the_map[(nx, y)] = the_map[(x, y)]
                    the_map[(robot[0], y)] = '.'
                    the_map[(robot[0] - 1, y)] = '@'
                    robot = (robot[0] - 1, y)
                    break
                x = nx
        else:
            raise Exception(f"Unknown move {move!r}")
        #print(f"\nAfter move {move!r}:")
        #print_map(the_map)
    return sum(
        x + 100*y
        for (x, y) in the_map
        if the_map[(x, y)] == "O"
    )

def solve2(stuff):
    global STEP_NUMBER
    (warehouse, moves) = stuff
    for (i, move) in enumerate(moves):
        print(f"{(i/len(moves)):6.2%}\r", end="")
        STEP_NUMBER = i
        debug(f"==== {STEP_NUMBER=} {move=}")
        debug(f"{warehouse!s}")
        if warehouse.robot.can_push(move, warehouse):
            warehouse.robot.do_push(move, warehouse)
    print()
    return sum(e.gps() for e in warehouse.map)



print("TEST 1A (expect 2028)")
print(solve1(parse(testa)))
print("TEST 1B (expect 10092)")
print(solve1(parse(testb)))
print("SOLVE 1")
print(solve1(parse(input_txt)))



# WAAAAY TOO SLOW, as in: was going to take an hour. See day15whee.py for a significantly optimized version.
print("TEST 2B (expect 9021)")
print(solve2(parse2(testb)))
print("SOLVE 2")
print(solve2(parse2(input_txt)))



