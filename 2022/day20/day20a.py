#!/bin/env python3


class Cell(object):
    def __init__(self, n):
        self.n = n
        self.prev = None
        self.next = None

    def excise(self):
        self.prev.next = self.next
        self.next.prev = self.prev

    def insert_after(self, prev):
        next = prev.next
        prev.next = self
        next.prev = self
        self.next = next
        self.prev = prev

    def skip(self, n):
        c = self
        for _ in range(n):
            c = c.next
        return c


with open("input.txt") as f:
    nums = [Cell(int(l.strip())) for l in f]

for c1, c2 in zip(nums, nums[1:]):
    c1.next = c2
    c2.prev = c1

nums[0].prev = nums[-1]
nums[-1].next = nums[0]

for c in nums:
    if c.n > 0:
        insert_after = c
        c.excise()
        for _ in range(c.n):
            insert_after = insert_after.next
        c.insert_after(insert_after)
    elif c.n < 0:
        insert_before = c
        c.excise()
        for _ in range(-c.n):
            insert_before = insert_before.prev
        c.insert_after(insert_before.prev)

zero = next(filter(lambda c: c.n == 0, nums))
c1k = zero.skip(1000)
c2k = c1k.skip(1000)
c3k = c2k.skip(1000)

# -5 is not right
print(c1k.n + c2k.n + c3k.n)
