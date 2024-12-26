with open('input.txt') as f:
    (_ins, rawgates) = f.read().strip().split("\n\n")

class Gate:
    def __init__(self, raw):
        [w1, op, w2, _, wout] = raw.split(" ")
        self.w1 = w1
        self.op = op
        self.w2 = w2
        self.wout = wout

    def __contains__(self, w):
        return self.w1 == w or self.w2 == w

    def __repr__(self):
        return f"{self.w1} {self.op} {self.w2} -> {self.wout}"

gates = [
    Gate(g) for g in rawgates.split("\n")
]

def print_gates():
    for g in gates:
        if 'x00' in g or 'y00' in g:
            print(g)

    print()

    for i in range(1,44):
        xg = None
        ag = None
        zg = None
        incarry = None
        carry = None
        for g in gates:
            if f'x{i:02}' in g:
                if g.op == "XOR":
                    xg = g
                elif g.op == "AND":
                    ag = g
        for g in gates:
            if xg.wout in g:
                if g.op == "XOR":
                    zg = g
                elif g.op == "AND":
                    incarry = g
            elif ag.wout in g:
                if g.op == "OR":
                    carry = g

        print(xg)
        print(f"  {zg}")
        print(f"  {incarry}")
        print(ag)
        print(f"  {carry}")
        print()
        # gbs,hwq,thm,wrm,wss,z08,z22,z29

if __name__ == '__main__':
    print_gates()
