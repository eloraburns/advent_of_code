import copy
import heapq

with open("testa.txt") as f:
    testa = f.read()

with open("input.txt") as f:
    input_txt = f.read()


class Node:
    INF_COST = 10**12-1

    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.connections = []
        self.best_cost = self.INF_COST
        self.best_cost_from = None

    def add(self, other, cost):
        self.connections.append((other, cost))

    def __lt__(self, other):
        return self.best_cost < other.best_cost

    def __repr__(self):
        return f"Node({self.x}, {self.y})"


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
                n = Node(x, y)
                all_nodes[(x, y)] = n
                if c == "S":
                    start = n
                elif c == "E":
                    end = n
    # Sets up all the actual maze paths
    maxy = len(shredded)
    maxx = len(shredded[0])
    for x in range(1, maxx):
        for y in range(1, maxy):
            if shredded[y][x] != "#":
                if shredded[y][x-1] != "#":
                    all_nodes[(x, y)].add(all_nodes[(x-1, y)], 1)
                if shredded[y][x+1] != "#":
                    all_nodes[(x, y)].add(all_nodes[(x+1, y)], 1)
                if shredded[y-1][x] != "#":
                    all_nodes[(x, y)].add(all_nodes[(x, y-1)], 1)
                if shredded[y+1][x] != "#":
                    all_nodes[(x, y)].add(all_nodes[(x, y+1)], 1)

    return (all_nodes, start, end)


def dijkstra(all_nodes, start, end, progress=False):
    start.best_cost = 0
    h = list(all_nodes.values())
    heapq.heapify(h)
    len_all = len(h)
    current_node = None
    while current_node is not end:
        current_node = heapq.heappop(h)
        if progress: print(f"{len(h)/len_all:6.2%}", end="\r")
        for (other, cost) in current_node.connections:
            if (newcost := current_node.best_cost + cost) < other.best_cost:
                other.best_cost = newcost
                other.best_cost_from = current_node
        # Doesn't seem to be a method for "bubble this one item to its correct spot"
        heapq.heapify(h)
    if progress: print()
    return current_node

def clear_nodes(all_nodes, start):
    for n in all_nodes:
        n.best_cost = n.INF_COST
        n.best_cost_from = None
    start.best_cost = 0

def solve1(raw, progress=False, debug=False):
    (all_nodes, start, end) = parse(raw)
    dijkstra(all_nodes, start, end, progress=progress)
    if progress: print(f"Fastest route takes {end.best_cost}ps")
    base_case = end.best_cost
    base_route = [end]
    current_node = end
    while current_node is not start:
        base_route.append(current_node := current_node.best_cost_from)
    base_route.reverse()
    if debug: print(f"Best base route: {base_route}")
    one_hundred_ps_club = 0
    for loc in base_route:
        (x, y) = (loc.x, loc.y)
        for nloc, nnloc in [
            ((x, y-1), (x, y-2)),
            ((x, y+1), (x, y+2)),
            ((x-1, y), (x-2, y)),
            ((x+1, y), (x+2, y))
        ]:
            if nloc not in all_nodes and nnloc in all_nodes:
                savings = all_nodes[nnloc].best_cost - loc.best_cost - 2
                if debug: print(f"  Found {savings=}ps")
                if savings >= 100:
                    one_hundred_ps_club += 1

    return one_hundred_ps_club

print("TEST 1A (expect 84 un-cheated ps)")
print(solve1(testa, progress=True, debug=True))

print("SOLVE 1")
print(solve1(input_txt, progress=True))
