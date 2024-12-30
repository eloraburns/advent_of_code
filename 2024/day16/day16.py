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

teste = (
    "####\n"
    "#.E#\n"
    "#S.#\n"
    "####\n"
)
teste_minimum_cost = 1002


with open("input.txt") as f:
    input_txt = f.read()

class Node:
    def __init__(self, x, y, direction):
        self.x = x
        self.y = y
        self.direction = direction
        self.connections = []
        self.best_cost = 10**12-1
        self.best_cost_from = set()

    def add(self, other, cost):
        self.connections.append((other, cost))

    def __lt__(self, other):
        return self.best_cost < other.best_cost

    def __repr__(self):
        connections = [((c.x, c.y, c.direction), cost) for (c, cost) in self.connections]
        best_cost_from = [(c.x, c.y, c.direction) for c in self.best_cost_from]
        return f"Node<{self.x}, {self.y}, {self.direction}, {self.best_cost}, {connections=}, {best_cost_from=}>"

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

def dijkstra(all_nodes, start, end, progress=False):
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
testa_minimum_cost = 7036
print(dijkstra(*parse(testa)).best_cost)
print("TEST 1B (expect 11048)")
# testb -> 11048
testb_minimum_cost = 11048
print(dijkstra(*parse(testb)).best_cost)
#print("RUN 1")
#print(dijkstra(*parse(input_txt), progress=True).best_cost)
# 123540
input_txt_minimum_cost = 123540

# For part B, we need to find _all_ minpaths. Since we already know what the
# min score actually is, it ought to be sufficiently cheap to just do
# a brute-force search from S to E, limiting cost to the known min.
# The search needs to remember the node list for all successful paths so we can
# union the coordinates of all paths at the end.

# Nope. Too dang expensive (22m and still running).
def find_all_paths(start, end, minimum_cost, path_so_far=frozenset(), cost_so_far=0, debug=False):
    path_so_far |= set([start])
    pad = "." * len(path_so_far)
    if start in end:
        coords_so_far = sorted([(n.x, n.y, n.direction) for n in path_so_far])
        if debug: print(f"{pad} RETURNING {coords_so_far=}")
        return [path_so_far]
    else:
        if debug:
            coords_so_far = sorted([(n.x, n.y, n.direction) for n in path_so_far])
            print(f"{pad} FROM {cost_so_far=} {coords_so_far=}")
    all_paths = []
    for (other, cost) in start.connections:
        if debug: print(f"{pad} TRYING {cost=} {other=} ", end="")
        if cost_so_far + cost <= minimum_cost and other not in path_so_far:
            if debug: print(f"yep")
            all_paths.extend(find_all_paths(
                other,
                end,
                minimum_cost,
                path_so_far,
                cost_so_far + cost,
                debug=debug
            ))
        else:
            if debug: print(f"nope")
    return all_paths

def spots_seen_from_all_paths(all_paths):
    return len(set((
        (n.x, n.y)
        for l in all_paths
        for n in l
    )))

def dijkstra2(all_nodes, start, ends, progress=False):
    start.best_cost = 0
    h = list(all_nodes.values())
    heapq.heapify(h)
    len_all = len(h)
    while h:
        current_node = heapq.heappop(h)
        if progress: print(f"{len(h)/len_all:6.2%}", end="\r")
        for (other, cost) in current_node.connections:
            newcost = current_node.best_cost + cost
            if newcost < other.best_cost:
                other.best_cost = newcost
                other.best_cost_from = set([current_node])
            elif newcost == other.best_cost:
                other.best_cost_from.add(current_node)
        # Doesn't seem to be a method for "bubble this one item to its correct spot"
        heapq.heapify(h)
    if progress: print()
    return ends

def find_all_path_coords(ends):
    min_cost = min((c.best_cost for c in ends))
    nodes_to_follow = set([e for e in ends if e.best_cost == min_cost])
    seen = set()
    while nodes_to_follow:
        n = nodes_to_follow.pop()
        seen.add((n.x, n.y))
        nodes_to_follow.update(n.best_cost_from)
    return len(seen)

def solve2(in_txt, progress=False):
    (all_nodes, start, ends) = parse(in_txt)
    dijkstra2(all_nodes, start, ends, progress=progress)
    return find_all_path_coords(ends)

print("RUN 1")
(all_nodes, start, ends) = parse(input_txt)
#print(dijkstra2(all_nodes, start, ends, progress=True))

print("TEST 2A (expect 45)")
print(solve2(testa))

print("TEST 2B (expect 64)")
print(solve2(testb))

print("TEST 2E (expect 3)")
print(solve2(teste))

print("RUN 2")
print(solve2(input_txt, progress=True))
