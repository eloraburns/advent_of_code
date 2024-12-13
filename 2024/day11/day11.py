# (did the first version on my ipad! Pythonista is 2.7 unfortunately, but it's
# better than nothing.)
from collections import Counter

test=[125, 17]

#def blink(stones):
#    new=[]
#    for stone in stones:
#        if stone == 0:
#            new.append(1)
#        else:
#            ss = str(stone)
#            sl = len(ss)
#            if sl % 2:
#                new.append(stone*2024)
#            else:
#                new.append(int(ss[:(sl>>1)]))
#                new.append(int(ss[(sl>>1):]))
#    return new

#thing = test
#print(thing)
#for i in range(6):
#    thing = blink(thing)
#    print(thing)
#for i in range(19):
#    thing=blink(thing)
#print("len", len(thing))

def blink(stonecounts):
    new = Counter()
    for (s, n) in stonecounts.items():
        if s == 0:
            new.update({1: n})
        else:
            ss = str(s)
            sl = len(ss)
            if sl % 2:
                new.update({(s*2024): n})
            else:
                new.update({int(ss[:(sl>>1)]): n})
                new.update({int(ss[(sl>>1):]): n})
    return new

thing = Counter(test)
print(thing)
for i in range(6):
    thing = blink(thing)
print("EXPECT 22")
print(sum(thing.values()))
for i in range(19):
    thing=blink(thing)
print ("EXPECT 55312")
print("len", sum(thing.values()))


import sys
with open("input.txt") as f:
    input_txt = [int(x) for x in f.read().strip().split()]

counts = Counter(input_txt)
for i in range(25):
    counts = blink(counts)
print("PART A", sum(counts.values()))

for i in range(25, 75):
    print(f"{i}", end="\r")
    counts = blink(counts)
print("\nPART B", sum(counts.values()))
