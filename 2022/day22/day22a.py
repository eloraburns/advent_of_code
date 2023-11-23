#!/env/bin python3

class Move(object):
    @staticmethod
    def parse(thing):
        if thing in "LR":
            return Turn(thing)
        else:
            return Forward(thing)

class Forward(Move):
    def __init__(self, distance):
        self.distance = int(distance)

class Turn(Move):
    def __init__(self, turn):
        self.turn = turn

class Turtle(object):
    def __init__(self, turtle_map):
        self.x = None
        for y, l in enumerate(turtle_map):
            for x, c in enumerate(l):
                if c == ".":
                    self.x = x
                    self.y = y
                    break
            if self.x:
                break
        self.direction = 0
        self.maxy = len(turtle_map)
        self.maxx = len(turtle_map[0])

    def turn_left(self):
        self.direction = (self.direction - 1) % 4

    def turn_right(self):
        self.direction = (self.direction + 1) % 4

    @property
    def next_location(self):
        if self.direction == 0:
            return (self.x + 1, self.y)
        elif self.direction == 1:
            return (self.x, self.y + 1)
        elif self.direction == 2:
            return (self.x - 1, self.y)
        else:
            return (self.x, self.y - 1)

    def make_move(self):
        self.x, self.y = self.next_location
        self.x %= self.maxx
        self.y %= self.maxy

class TurtleMap(object):
    def __init__(self, m, directions):
        self.map = self.parse_map(m)
        self.directions = directions

    @staticmethod
    def parse_map(m):
        lines = m.split("\n")
        height = len(lines)
        width = len(lines[0])
        # Adjust for 1-based addressing
        lines = [" " * width] + lines
        lines = [" " + l for l in lines]

    @staticmethod
    def parse_directions(d):
        dirs = []
        stuff = (m.group(1) for m in re.finditer(r"(\d+|[LR])", d))
        while True:
            dirs.append(next(stuff)

    def walk(self, turtle):
        for d in self.directions:
            if isinstance(d, Move):
                for _ in range(d.distance):
                    potential_x, potential_y = turtle.next_location
                    if self.map[y][x] == ".":
                        turtle.make_move()
                    elif 
            elif isinstance(d, Turn):
                if d.turn == "R":
                    turtle.turn_right()
                elif d.turn == "L":
                    turtle.turn_left()
                else:
                    raise Exception("what direction is that?")
                turtle.direction %= 4
            else:
                raise Exception("What move is that?!?!")
                
            

with open("test.txt") as f:
    turtle = TurtleMap(*f.read().split("\n\n"))
