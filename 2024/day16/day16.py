# testa -> 7036
# testb -> 11048
#
# The Reindeer start on the Start Tile (marked S) facing East and need to reach
# the End Tile (marked E). They can move forward one tile at a time (increasing
# their score by 1 point), but never into a wall (#). They can also rotate
# clockwise or counterclockwise 90 degrees at a time (increasing their score by
# 1000 points).

import heapq

N = "N"
E = "E"
S = "S"
W = "W"

with open("testa.txt") as f:
    testa = f.read()

with open("testb.txt") as f:
    testb = f.read()

with open("input.txt") as f:
    input_txt = f.read()

class Node:
    def __init__(self, x, y, direction):
        self.x = x
        self.y = y
        self.direction = direction
        self.connections = []
        self.best_cost = 10**12-1

    def add(self, other, cost):
        self.connections.append((other, cost))

    def __lt__(self, other):
        return self.best_cost < other.best_cost

    def __repr__(self):
        connections = [((c.x, c.y, c.direction), cost) for (c, cost) in self.connections]
        return f"Node<{self.x}, {self.y}, {self.direction}, {self.best_cost}, {connections}>"

class Edge:
    def __init__(self, cost, target):
        self.cost = cost
        self.target = target

def parse(raw):
    shredded = [
        [
            c
            for c in l
        ]
        for l in raw.strip().split("\n")
    ]
    all_nodes = {}
    # Sets up all the the rotational nodes on open squares
    for (y, l) in enumerate(shredded):
        for (x, c) in enumerate(l):
            if c in "SE.":
                n = Node(x, y, N)
                e = Node(x, y, E)
                s = Node(x, y, S)
                w = Node(x, y, W)
                n.add(e, 1000)
                e.add(s, 1000)
                s.add(w, 1000)
                w.add(n, 1000)
                n.add(w, 1000)
                w.add(s, 1000)
                s.add(e, 1000)
                e.add(n, 1000)
                all_nodes[(x, y, N)] = n
                all_nodes[(x, y, E)] = e
                all_nodes[(x, y, S)] = s
                all_nodes[(x, y, W)] = w
                if c == "S":
                    start = e
                elif c == "E":
                    end = [n, e, s, w]
    # Sets up all the actual maze paths
    maxy = len(shredded)
    maxx = len(shredded[0])
    for x in range(1, maxx):
        for y in range(1, maxy):
            if shredded[y][x] != "#":
                if shredded[y][x-1] != "#":
                    all_nodes[(x, y, W)].add(all_nodes[(x-1, y, W)], 1)
                if shredded[y][x+1] != "#":
                    all_nodes[(x, y, E)].add(all_nodes[(x+1, y, E)], 1)
                if shredded[y-1][x] != "#":
                    all_nodes[(x, y, N)].add(all_nodes[(x, y-1, N)], 1)
                if shredded[y+1][x] != "#":
                    all_nodes[(x, y, S)].add(all_nodes[(x, y+1, S)], 1)

    return (all_nodes, start, end)

def djikstra(all_nodes, start, end, progress=False):
    start.best_cost = 0
    h = list(all_nodes.values())
    heapq.heapify(h)
    len_all = len(h)
    current_node = heapq.heappop(h)
    while current_node not in end:
        if progress: print(f"{len(h)/len_all:6.2%}", end="\r")
        for (other, cost) in current_node.connections:
            if (newcost := current_node.best_cost + cost) < other.best_cost:
                other.best_cost = newcost
        # Doesn't seem to be a method for "bubble this one item to its correct spot"
        heapq.heapify(h)
        current_node = heapq.heappop(h)
    if progress: print()
    return current_node

print("TEST 1A (expect 7036)")
# testa -> 7036
print(djikstra(*parse(testa)).best_cost)
print("TEST 1B (expect 11048)")
# testb -> 11048
print(djikstra(*parse(testb)).best_cost)
print("RUN 1")
print(djikstra(*parse(input_txt), progress=True).best_cost)

