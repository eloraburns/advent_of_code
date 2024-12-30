from collections import Counter
from pprint import pprint
import itertools

try:
    import re2 as re
    have_re2 = True
except ImportError:
    import re # but this won't actually succeed on input.txt
    have_re2 = False

with open("testa.txt") as f:
    testa = f.read()

with open("input.txt") as f:
    input_txt = f.read()


def parse(raw):
    (towels, patterns) = raw.strip().split("\n\n")
    return (towels.split(", "), patterns.split("\n"))

def solve1(raw):
    towels, patterns = parse(raw)
    towels_re_string = f"^({'|'.join(towels)})+$"
    print(towels_re_string)
    towels_re = re.compile(towels_re_string)
    return sum(bool(towels_re.match(pattern)) for pattern in patterns)

print("TEST 1A (expect 6)")
print(solve1(testa))
if have_re2:
    print("SOLVE 1")
    print(solve1(input_txt))

#class Cursor:
#    def __init__(self, strings, cursors, current_string=None):
#        self.strings = strings
#        self.cursors = cursors
#        cursors.add(self)
#        self.current_string = current_string
#
#    @property
#    def accept_state(self):
#        return not self.current_string
#
#    def consume(self, char):
#        if not self.current_string:
#            usable_strings = [s for s in self.strings if s[0] == char]
#            if usable_strings:
#                self.current_string = usable_strings[0][1:]
#                for us in usable_strings[1:]:
#                    Cursor(self.strings, self.cursors, us[1:])
#            else:
#                self.cursors.remove(self)
#        elif self.current_string.startswith(char):
#            self.current_string = self.current_string[1:]
#        else:
#            self.cursors.remove(self)
#
#    def __repr__(self):
#        return f"Cursor<{self.current_string=!r}>"

#def solve1_myself(raw, debug=False, debug2=False):
#    towels, patterns = parse(raw)
#    if debug: print(f"{towels=}")
#    usable = 0
#    for p in patterns:
#        if debug: print(f"Working on {p!r}")
#        cursors = set()
#        Cursor(towels, cursors)
#        for c in p:
#            if debug and not debug2: print(f"  {len(cursors)=}         ", end="")
#            if debug2: print(f"  {cursors}")
#            if debug2: print(f"  feeding {c=}")
#            for cursor in list(cursors):
#                cursor.consume(c)
#        if debug2: print(f"  {cursors}")
#        if debug and not debug2: print()
#        if any(cursor.accept_state for cursor in cursors):
#            usable += 1
#    return usable

# Given a regex like:
#     (abc|ab|cd|xy)*
# We generate a data structure like:
# start = {
#     'a': {
#         'b': {
#             TERMINAL: start,
#             'c': {
#                 TERMINAL: start
#             },
#         },
#     },
#     'c': {
#         'd': {
#             TERMINAL: start
#         }
#     },
#     'x': {
#         'y': {
#             TERMINAL: start
#         }
#     }
# }

# Always start at `start`. Consume the first letter of the input.
# If it doesn't exist, this cursor is "dead".
# If it does exist, and it has a TERMINAL key, then we need to split the cursor:
#   one to continue the match, and another 

TERMINAL = object()

def make_network(start, current, towel_fragments):
    if not towel_fragments:
        return
    for (initial, frags) in itertools.groupby(towel_fragments, lambda x: x[0]):
        frags = list(frags)
        #print(f" {initial=} {frags=}")
        subfrags = [frag[1:] for frag in frags if frag[1:]]
        current[initial] = {}
        make_network(start, current[initial], subfrags)
        if initial in frags:
            current[initial][TERMINAL] = start

class Cursor:
    def __init__(self, state):
        self.state = state

    def consume(self, char):
        #print(f"  {id(self)=} consume {char=} {self.state=}")
        new_cursors = []
        if char not in self.state:
            return new_cursors
        elif TERMINAL in self.state[char]:
            terminal_state = self.state[char][TERMINAL]
            new_cursors.append(Cursor(terminal_state))
        self.state = self.state[char]
        new_cursors.append(self)
        return new_cursors

    def __hash__(self):
        return id(self.state)

    def __eq__(self, other):
        return self.state is other.state

    def __repr__(self):
        return f"Cursor(next_states={list(self.state.keys())})"

def solve1_just_one(start, pattern, debug=False):
    cursors = [Cursor(start)]
    for c in pattern:
        #if debug: print(f"{len(cursors)=}      \r", end="")
        if debug: print(f"  {cursors}")
        if debug: input()
        cursors = set([
            cursor
            for cursur in cursors
            for cursor in cursur.consume(c)
        ])
    if debug: print(f"{len(cursors)=}      ")
    return any(cursor.state is start for cursor in cursors)

def solve1_myself(raw):
    start = {}
    (towels, patterns) = parse(raw)
    towels.sort()
    make_network(start, start, towels)
    #pprint(start)
    possible = 0
    for pattern in patterns:
        #print(pattern)
        print(".", end="")
        possible += solve1_just_one(start, pattern)
    print("!")
    return possible





print("TEST 1A MYSELF (expect 6)")
print(solve1_myself(testa))

print("TEST LOCAL")
print(solve1_myself("""a, ab

a
aa
aaa
ab
aba
b
ba
"""))

print("SOLVE 1 MYSELF (expect 330)")
print(solve1_myself(input_txt))
# For some reason ruruwbrwgugrwgbugugwbubbwgggwggurruwguwbwwu (and a bunch of others) passes, when it shouldn't. (ah, I missed a "step state forward" case in the Cursor, fixed now)

def solve2_just_one(start, pattern, debug=False):
    cursors = Counter([Cursor(start)])
    for c in pattern:
        #if debug: print(f"{len(cursors)=}      \r", end="")
        if debug: print(f"  {cursors}")
        if debug: input()
        new_cursors = Counter()
        for cursor, count in cursors.items():
            for just_fed in cursor.consume(c):
                # This is "memoizing" our cursors. There are SO MANY, but any
                # given cursor is identical to others (state-wise) if it has
                # the same state. We do care about their numeracy, because that
                # tells us how many distinct matches there are. But we can
                # track numeracy with a simple integer. Yay Counter().
                new_cursors[just_fed] += count
        cursors = new_cursors
    if debug: print(f"{len(cursors)=}      ")
    # dicts aren't hashable…but our Cursor sure is…since it just punts and uses
    # the underlying state for identity.
    return cursors[Cursor(start)]


# This is … actually exactly the same, except it calls solve2_just_one
def solve2_myself(raw):
    start = {}
    (towels, patterns) = parse(raw)
    towels.sort()
    make_network(start, start, towels)
    possible = 0
    for pattern in patterns:
        print(".", end="")
        possible += solve2_just_one(start, pattern)
    print("!")
    return possible






print("TEST 2A (expect 16)")
print(solve2_myself(testa))

print("SOLVE 2")
print(solve2_myself(input_txt))
