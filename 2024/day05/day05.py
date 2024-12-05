import sys

def parse(raw_input):
    [raw_rules, raw_updates] = raw_input.split("\n\n")
    rules = [tuple(map(int, l.strip().split("|"))) for l in raw_rules.split()]
    updates = [list(map(int, l.strip().split(","))) for l in raw_updates.split()]
    return (rules, updates)

def update_passes(rules, update):
    s = set(update)
    for (a, b) in rules:
        if a in s and b in s and update.index(a) > update.index(b):
                return False
    return True

def get_middle(update):
    return update[len(update)//2]

def reordered(rules, update):
    #print("REORDERING", update)
    new = update[:1]
    for u in update[1:]:
        #print("  INSERTING", u)
        for i in range(len(new) + 1):
            new2 = new[:i] + [u] + new[i:]
            #print("    TESTING", new2)
            if update_passes(rules, new2):
                new = new2
                #print("  PROGRESS", new)
                break
    #print("  DONE", new)
    return new

def part_a(rules, updates):
    acc = 0
    for update in updates:
        if update_passes(rules, update):
            print("$",end="")
            acc += get_middle(update)
        else:
            print(".",end="")
    print()
    return acc

def part_b(rules, updates):
    acc = 0
    for update in updates:
        if not update_passes(rules, update):
            print("$",end="")
            #sys.stdout.flush()
            acc += get_middle(reordered(rules, update))
        else:
            print(".",end="")
            #sys.stdout.flush()
    print()
    return acc

with open("input.txt") as f:
    input_txt = parse(f.read())

with open("testa.txt") as f:
    testa = parse(f.read())

print("TEST PART A (expect 143)")
print(part_a(*testa))
print("TEST PART B (expect 123)")
print(part_b(*testa))


print("PART A")
print(part_a(*input_txt))

print("PART B")
print(part_b(*input_txt))
