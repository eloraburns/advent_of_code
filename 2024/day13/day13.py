import re
import time

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

    def __sub__(self, other):
        return Pair(self.x - other.x, self.y - other.y)

    def __rmul__(self, mult):
        return Pair(self.x * mult, self.y * mult)

    def __floordiv__(self, other):
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

def parse_b(raw):
    games = []
    for rawgame in raw.strip().split("\n\n"):
        game = ClawGame(rawgame)
        game.prize = game.prize + Pair(10000000000000, 10000000000000)
        games.append(game)
    return games

def gcd(a, b):
    while b:
        t = b
        b = a % b
        a = t
    return a

def lcm(a, b):
    return a * b // gcd(a, b)

def solve_a_game(game):
    print(game)
    a_count = 0
    b_count = game.prize // game.b
    agg_lcm = lcm(lcm(game.a.x, game.b.x), lcm(game.a.y, game.b.y))
    print(f"{agg_lcm=}")
    for x in range(agg_lcm):
        if b_count < 0:
            break
        current_location = a_count * game.a + b_count * game.b
        #print(f"  {a_count=} {b_count=} {current_location=} difference={game.prize - current_location}")
        if current_location == game.prize:
            return a_count*3 + b_count
        elif current_location > game.prize:
            b_count -= 1
        else:
            a_count += 1
    ##for a in range(101):
    ##    for b in range(100, -1, -1):
    ##        if game.a * a + game.b * b == game.prize:
    ##            return a*3 + b
    #print(".", end="")
    return 0

def part_a(games):
    return sum(solve_a_game(game) for game in games)

print("PART A")
print("TEST EXPECTS 480")
print(f"TEST RETURNS {part_a(parse(testa_txt))}")
print(f"ACTUAL RETURNS {part_a(parse(input_txt))}")

bgames = parse_b(testa_txt)
print("DEBUGGING")
print(f"\nRunning the first game {bgames[0]}")
print(f"Solving returns {part_a(bgames[:1])}")
print(f"\nRunning the second game {bgames[1]}")
print(f"Solving returns {part_a(bgames[1:2])}")


#print("PART B")
#print("TEST EXPECTS ???")
#print(f"TEST RETURNS {part_a(bgames)}")
#print(f"ACTUAL RETURNS {part_a(parse_b(input_txt))}")
