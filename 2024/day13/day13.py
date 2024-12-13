import re

with open("testa.txt") as f:
    testa_txt = f.read()

with open("input.txt") as f:
    input_txt = f.read()


class Pair:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Pair({self.x}, {self.y})"

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    def __gt__(self, other):
        return self.x > other.x or self.y > other.y

    def __add__(self, other):
        return Pair(self.x + other.x, self.y + other.y)

    def __mul__(self, mult):
        return Pair(self.x * mult, self.y * mult)

    def __div__(self, other):
        return min(self.x // other.x, self.y // other.y)

class ClawGame:
    claw_re = re.compile(
        r'Button A: X\+(?P<ax>\d+), Y\+(?P<ay>\d+)\n'
        r'Button B: X\+(?P<bx>\d+), Y\+(?P<by>\d+)\n'
        r'Prize: X=(?P<px>\d+), Y=(?P<py>\d+)'
     )

    def __init__(self, raw):
        m = self.claw_re.match(raw)
        self.a = Pair(int(m.group("ax")), int(m.group("ay")))
        self.b = Pair(int(m.group("bx")), int(m.group("by")))
        self.prize = Pair(int(m.group("px")), int(m.group("py")))

    def __repr__(self):
        return f"ClawGame<A={self.a}, B={self.b}, P={self.prize}>"

def parse(raw):
    return [
        ClawGame(game)
        for game in raw.strip().split("\n\n")
    ]

def solve_a_game(game):
    for a in range(101):
        for b in range(100, -1, -1):
            if game.a * a + game.b * b == game.prize:
                return a*3 + b
    return 0

def part_a(games):
    return sum(solve_a_game(game) for game in games)

print("PART A")
print("TEST EXPECTS 480")
print(f"TEST RETURNS {part_a(parse(testa_txt))}")
print(f"ACTUAL RETURNS {part_a(parse(input_txt))}")
