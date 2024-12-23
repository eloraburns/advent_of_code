from collections import defaultdict
from itertools import islice

with open("testa.txt") as f:
    testa = [int(i) for i in f.read().strip().split("\n")]

with open("input.txt") as f:
    input_txt = [int(i) for i in f.read().strip().split("\n")]

def pseudogen(seed):
    """
    >>> import itertools
    >>> list(itertools.islice(pseudogen(123), 10))
    [123, 15887950, 16495136, 527345, 704524, 1553684, 12683156, 11100544, 12249484, 7753432]
    """
    while True:
        yield seed
        seed ^= seed << 6
        seed &= 0xFFFFFF
        seed ^= seed >> 5
        # This isn't necessary beacuse we're already doing bitshifts
        # seed &= 0xFFFFFF
        seed ^= seed << 11
        seed &= 0xFFFFFF

def solvea(inputs):
    return sum(next(islice(pseudogen(i), 2000, 2001, 1)) for i in inputs)

#print("TEST A (expect 37327623)")
#print(solvea(testa))
#
#print("SOLVE A")
#print(solvea(input_txt))

def deltas(iterable):
    """
    >>> import itertools
    >>> list(deltas(iter([1, 1, 2, 3, 5, 0, 8, 3])))
    [0, 1, 1, 2, -5, 8, -5]
    """
    try:
        a = next(iterable)
    except StopIteration:
        return
    for b in iterable:
        yield b - a
        a = b

def mod10(iterable):
    for i in iterable:
        yield i % 10

def costmaps(seed):
    pg10 = mod10(pseudogen(seed))
    a = next(pg10)
    b = next(pg10)
    c = next(pg10)
    d = next(pg10)
    m = {}
    for _ in range(1997):
        e = next(pg10)
        pat = (b-a, c-b, d-c, e-d)
        m.setdefault(pat, e)
        a = b
        b = c
        c = d
        d = e
    return m

testb = [1, 2, 3, 2024]

print("MANUAL TEST B (expect 23)")
#testb_pat = (-2,1,-1,3)
testb_pat = (5, 1, -1, 5)
print(f"LOOKING FOR {testb_pat}")
print(f"{costmaps(1).get(testb_pat, 0)=}")
print(f"{costmaps(2).get(testb_pat, 0)=}")
print(f"{costmaps(3).get(testb_pat, 0)=}")
print(f"{costmaps(2024).get(testb_pat, 0)=}")

def solveb(seeds):
    print("seedmapping")
    seedmaps = [costmaps(seed) for seed in seeds]
    merged_maps = defaultdict(int)
    print("mergemapping")
    for m in seedmaps:
        for k, v in m.items():
            merged_maps[k] += v
    #print(sorted([(v, k) for k, v in merged_maps.items()]))
    print("done")
    return max(merged_maps.values())
    #for j in range(len(seedmaps)):
    #    m = seedmaps[j]
    #    while m and (item := m.popitem()):
    #        k, v = item
    #        score = sum(m2.pop(k, 0) for m2 in seedmaps[j+1:]) + v
    #        print(f"{k=}\t{score=}")
    #        best_score = max(best_score, score)
    #return best_score

print("TEST B (expect 23)")
print(solveb(testb))

print("SOLVE B")
print(solveb(input_txt))
