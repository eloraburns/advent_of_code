from itertools import combinations
from pprint import pprint

with open("testa.txt") as f:
    testa = [
        l.split("-")
        for l in f.read().strip().split("\n")
    ]

with open("input.txt") as f:
    input_txt = [
        l.split("-")
        for l in f.read().strip().split("\n")
    ]

class Comp:
    def __init__(self, name):
        self.name = name
        self.connections = set()

    def connect_to(self, other):
        self.connections.add(other)

    def __repr__(self):
        conns = ",".join((c.name for c in self.connections))
        return f"Comp({self.name!r}, <{conns}>)"

def connect_comps(connections):
    comps = {}
    for (ca, cb) in connections:
        if ca not in comps:
            comps[ca] = Comp(ca)
        if cb not in comps:
            comps[cb] = Comp(cb)
        comps[ca].connect_to(comps[cb])
        comps[cb].connect_to(comps[ca])
    return comps

def solvea(connections):
    comps = connect_comps(connections)
    seen_3nets = set()
    for comp in comps.values():
        #print(f" Checking {comp=}")
        for (oa, ob) in combinations(comp.connections, 2):
            if (
                comp in oa.connections and
                comp in ob.connections and
                oa in ob.connections and
                ob in oa.connections
            ):
                seen_3nets.add(threenet := frozenset([comp.name, oa.name, ob.name]))
                #print(f"   found {threenet=}")
    tgroups = 0
    for (a, b, c) in seen_3nets:
        if a[0] == "t" or b[0] == "t" or c[0] == "t":
            tgroups += 1
    return tgroups

def bron_kerbosch_1(p):
    return _bron_kerbosch_1(frozenset(), frozenset(p), frozenset())

def _bron_kerbosch_1(r, p, x):
    if not p and not x:
        return [r]
    cliques = []
    runningp = p
    runningx = x
    for v in p:
        r1 = r.union([v])
        p1 = runningp.intersection(v.connections)
        x1 = x.intersection(v.connections)
        cliques.extend(_bron_kerbosch_1(r1, p1, x1))
        runningp = runningp.difference([v])
        runningx = runningx.union([v])
    return cliques

def solveb(connections):
    comps = connect_comps(connections)
    cliques = bron_kerbosch_1(comps.values())
    maxclique = max(cliques, key=len)
    members = sorted(set([
        comp.name
        for comp in maxclique
    ]))
    return ",".join(members)

print()
print("TEST A (expect 7)")
print(solvea(testa))
print("SOLVE A")
print(solvea(input_txt))
print()
print("TEST B (expect 'co,de,ka,ta')")
print(solveb(testa))
print("SOLVE B")
print(solveb(input_txt))

