import re

xmas_re = re.compile(r'XMAS')

def arrayify(raw_input):
    return raw_input.strip().split()

def vflip(a):
    return list(reversed(a))

def hflip(a):
    return ["".join(reversed(l)) for l in a]

def transpose(a):
    return ["".join(z) for z in zip(*a)]

#def diagonalize(a):
#    width = len(a[0])
#    height = len(a)
#    d = [[]] * height
#    for y in range(height):
#        for x in range(y):
#            d[y].append(a[y-x][y])
#    for pseudo_y in range(width):
#        for x in range(pseudo_y + 1, width):
#            d[height + pseudo_y].append(a[height-x][x])
#    return d

def mapify(a):
    m = {}
    width = len(a[0])
    height = len(a)
    for x in range(width):
        for y in range(height):
            m[(x, y)] = a[y][x]
    return m

def diagonalize(a):
    width = len(a[0])
    height = len(a)
    m = mapify(a)
    d = []
    for x in range(-height+1, width):
        dacc = []
        for y_ish in range(height):
            if letter := m.get((x + y_ish, height - 1 - y_ish)):
                dacc.append(letter)
        d.append("".join(dacc))
    return d

def xmases(a):
    return sum(len(xmas_re.findall(l)) for l in a)

def part_a(crossword):
    count = 0
    count += xmases(crossword)
    count += xmases(hflip(crossword))

    tcrossword = transpose(crossword)
    count += xmases(tcrossword)
    count += xmases(hflip(tcrossword))

    dcrossword = diagonalize(crossword)
    count += xmases(dcrossword)
    count += xmases(hflip(dcrossword))

    dtcrossword = diagonalize(hflip(crossword))
    count += xmases(dtcrossword)
    count += xmases(hflip(dtcrossword))

    return count

def is_x(x, y, m):
    # M.S
    # .A.
    # M.S
    allowed = [
        ["M", "M", "S", "S"],
        ["S", "M", "M", "S"],
        ["S", "S", "M", "M"],
        ["M", "S", "S", "M"],
    ]
    if m.get((x, y)) == "A" and [
                m.get((x-1, y-1)),
                m.get((x+1, y-1)),
                m.get((x+1, y+1)),
                m.get((x-1, y+1)),
            ] in allowed:
        return True
    return False

def part_b(crossword):
    m = mapify(crossword)
    (maxx, maxy) = max(m.keys())

    count = 0
    for x in range(maxx):
        for y in range(maxy):
            if is_x(x, y, m):
                count += 1
    return count

with open("input.txt") as f:
    crossword = arrayify(f.read())

with open("testa.txt") as f:
    testa = arrayify(f.read())

print("TEST PART A (expect 18)")
print(part_a(testa))
print("TEST PART B (expect 9)")
print(part_b(testa))


print("PART A")
print(part_a(crossword))

print("PART B (2044 IS TOO HIGH)")
print(part_b(crossword))

#unittest = [
#    "XMAS",
#    "FOOD",
#]
#print("UNITTEST - diagonalize")
#print(unittest)
#print(diagonalize(unittest))
