import heapq

with open("testa.txt") as f:
    testa = f.read()
    testa_size = 7
    testa_steps = 12

with open("input.txt") as f:
    input_txt = f.read()
    input_txt_size = 71
    input_txt_steps = 1024

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

class Node:
    INF_COST = 10**12-1
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.connections = []
        self.best_cost = self.INF_COST

    def add(self, other, cost):
        self.connections.append((other, cost))

    def __lt__(self, other):
        return self.best_cost < other.best_cost

    def __repr__(self):
        connections = [((c.x, c.y), cost) for (c, cost) in self.connections]
        return f"Node<{self.x}, {self.y}, {self.best_cost}, {connections}>"

class Edge:
    def __init__(self, cost, target):
        self.cost = cost
        self.target = target

def generate(raw, size, steps):
    drops = set([
        tuple(map(int, l.split(",")))
        for l in raw.strip().split("\n")
    ][:steps])
    shredded = []
    for y in range(size):
        row = []
        for x in range(size):
            if (x, y) in drops:
                row.append("#")
            else:
                row.append(".")
        shredded.append(row)
    return shredded

def parse(shredded):
    all_nodes = {}
    for (y, l) in enumerate(shredded):
        for (x, c) in enumerate(l):
            if c == ".":
                all_nodes[(x, y)] = Node(x, y)
    # Sets up all the actual maze paths
    for ((x, y), node) in all_nodes.items():
        for neighbour_coord in [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]:
            if neighbour := all_nodes.get(neighbour_coord):
                node.add(neighbour, 1)

    yrange = len(shredded)
    xrange = len(shredded[0])
    return (all_nodes, all_nodes[(0, 0)], all_nodes[(xrange-1, yrange-1)])

def djikstra(all_nodes, start, end, progress=False):
    start.best_cost = 0
    h = list(all_nodes.values())
    heapq.heapify(h)
    len_all = len(h)
    current_node = heapq.heappop(h)
    while current_node is not end:
        if progress: print(f"{len(h)/len_all:6.2%}", end="\r")
        for (other, cost) in current_node.connections:
            if (newcost := current_node.best_cost + cost) < other.best_cost:
                other.best_cost = newcost
        # Doesn't seem to be a method for "bubble this one item to its correct spot"
        heapq.heapify(h)
        current_node = heapq.heappop(h)
    if progress: print()
    return current_node

def solveb(raw, size, progress=False):
    drops = raw.strip().split("\n")
    num_drops = len(drops)
    lower_bound = 0
    upper_bound = num_drops
    next_try = num_drops // 2
    while True:
        print(f"  Trying {lower_bound=} {next_try=} {upper_bound=} ", end="")
        if lower_bound + 1 == upper_bound:
            print("FOUND")
            return drops[upper_bound - 1]
        best_cost = djikstra(*parse(generate(raw, size, next_try)), progress).best_cost
        print(f"{best_cost=}")
        if best_cost < Node.INF_COST:
            lower_bound = next_try
            next_try = (upper_bound + lower_bound) // 2
        else:
            upper_bound = next_try
            next_try = (upper_bound + lower_bound) // 2

print("TEST 1A (expect 22)")
#print(f"{testa=} {testa_size=} {testa_steps=}")
#print(generate(testa, testa_size, testa_steps))
print(djikstra(*parse(generate(testa, testa_size, testa_steps))).best_cost)

print("RUN 1")
print(djikstra(*parse(generate(input_txt, input_txt_size, input_txt_steps)), progress=True).best_cost)

print("TEST 2A (expect 6,1)")
print(solveb(testa, testa_size))

print("RUN 2")
print(solveb(input_txt, input_txt_size, progress=True))
