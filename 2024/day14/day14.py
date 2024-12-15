TEST_SIZE = (11, 7)
INPUT_SIZE = (101, 103)

import re

with open("testa.txt") as f:
    testa = f.read()

with open("input.txt") as f:
    input_txt = f.read()

class Robot:
    def __init__(self, x, y, dx, dy):
        self.x = x
        self.y = y
        self.dx = dx
        self.dy = dy

    def __repr__(self):
        return f"(Robot({self.x}, {self.y}, {self.dx}, {self.dy})"

    def moved_nsteps_in_size(self, nsteps, size):
        (xsize, ysize) = size
        return Robot(
            (self.x + self.dx * nsteps) % xsize,
            (self.y + self.dy * nsteps) % ysize,
            self.dx,
            self.dy
        )

def parse(raw):
    robots = []
    for str_ints in re.findall(r'p=(\d+),(\d+) v=(-?\d+),(-?\d+)', raw):
        robots.append(Robot(*[int(a) for a in str_ints]))
    return robots

def solvea(robots, steps, size):
    moved_robots = [
        robot.moved_nsteps_in_size(steps, size)
        for robot in robots
    ]
    halfx = size[0] // 2
    halfy = size[1] // 2
    quads = [0, 0, 0, 0]
    for robot in moved_robots:
        if robot.x < halfx:
            if robot.y < halfy:
                quads[0] += 1
            elif robot.y > halfy:
                quads[1] += 1
        elif robot.x > halfx:
            if robot.y < halfy:
                quads[2] += 1
            elif robot.y > halfy:
                quads[3] += 1
    return quads[0] * quads[1] * quads[2] * quads[3]

print("TEST A (expect 12)")
print(solvea(parse(testa), 100, TEST_SIZE))
print("SOLVE A")
print(solvea(parse(input_txt), 100, INPUT_SIZE))

def print_bots(bots):
    occupied = set(
        (robot.x, robot.y)
        for robot in bots
    )
    for y in range(INPUT_SIZE[1]):
        for x in range(INPUT_SIZE[0]):
            if (x, y) in occupied:
                print("*", end="")
            else:
                print(".", end="")
        print("")

import time
bots = parse(input_txt)
# t=33 had a horizontal pattern
# t=68 had a vertical pattern
# t=136 had a horizontal pattern
# t=169 had a vertical pattern
# Vertical patterns repeat every 101s
# Horizontal patterns repeate every 103s
# So we're just looking for t = 33 + n*103
# which should happen for n<101.
# Turns out t=7037, when n=68.
for t in range(33, 100000, 103):
    print(f"\n{t=}")
    print_bots(bot.moved_nsteps_in_size(t, INPUT_SIZE) for bot in bots)
    print()
    time.sleep(0.1)

