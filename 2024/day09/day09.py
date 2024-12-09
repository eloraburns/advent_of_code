import sys

def parse(raw):
    disk = []
    fileno = 0
    it = iter(raw)
    try:
        while True:
            datalen = int(next(it))
            disk.extend([fileno] * datalen)
            fileno += 1
            freelen = int(next(it))
            disk.extend([None] * freelen)
    except StopIteration:
        return disk

class File:
    def __init__(self, length, number):
        self.length = length
        self.number = number

    def __repr__(self):
        return f"File({self.length}, {self.number})"

class Free:
    def __init__(self, length):
        self.length = length

    def __repr__(self):
        return f"Free({self.length})"

def parse_b(raw):
    disk = []
    fileno = 0
    it = iter(raw)
    try:
        while True:
            datalen = int(next(it))
            disk.append(File(datalen, fileno))
            fileno += 1
            freelen = int(next(it))
            disk.append(Free(freelen))
    except StopIteration:
        return (disk, fileno - 1)

def part_a(raw):
    disk = parse(raw)
    # Initialize
    free_idx = disk.index(None)
    last_used_idx = len(disk) - 1
    while disk[last_used_idx] is None:
        last_used_idx -= 1

    # Defragment
    while free_idx < last_used_idx:
        (disk[free_idx], disk[last_used_idx]) = (disk[last_used_idx], disk[free_idx])
        free_idx = disk.index(None, free_idx)
        while disk[last_used_idx] is None:
            last_used_idx -= 1

    # Checksum
    checksum = 0
    for (i, n) in enumerate(disk):
        if n is not None:
            checksum += i * n
    return checksum

def part_b(raw):
    (disk, fileno) = parse_b(raw)

    while fileno > 0:
        for i in range(len(disk) - 1, 0, -1):
            if isinstance(disk[i], File) and disk[i].number == fileno:
                file_idx = i
                break
        for free_idx in range(file_idx):
            if isinstance(disk[free_idx], Free):
                if disk[free_idx].length >= disk[file_idx].length:
                    # split free space and move file
                    remaining_free = Free(disk[free_idx].length - disk[file_idx].length)
                    previously_used = Free(disk[file_idx].length)
                    disk[free_idx] = disk[file_idx]
                    disk[file_idx] = previously_used
                    disk.insert(free_idx + 1, remaining_free)
                    break
                elif disk[free_idx].length == disk[file_idx].length:
                    # swap
                    (disk[free_idx], disk[file_idx]) = (disk[file_idx], disk[free_idx])
        fileno -= 1

    checksum = 0
    i = 0
    for chunk in disk:
        if chunk.__class__ is Free:
            i += chunk.length
        else:
            for j in range(i, i + chunk.length):
                checksum += j * chunk.number
            i += chunk.length
    return checksum

with open("input.txt") as f:
    input_txt = f.read().strip()

with open("testa.txt") as f:
    testa = f.read().strip()

print("TEST PART A (expect 1928)")
print(part_a(testa))
print("TEST PART B (expect 2858)")
print(part_b(testa))


print()
print("PART A")
print(part_a(input_txt))

print("PART B")
print(part_b(input_txt))
