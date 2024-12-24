with open("test1.txt") as f:
    test1 = f.read()

with open("test2.txt") as f:
    test2 = f.read()

with open("input.txt") as f:
    input_txt = f.read()

def parse(raw):
    (rawins, rawgates) = raw.strip().split("\n\n")
    ins = []
    for l in rawins.split("\n"):
        w = l.split(": ")
        ins.append((w[0], bool(int(w[1]))))
    gates = []
    for l in rawgates.split("\n"):
        [w1, op, w2, _, wout] = l.split(" ")
        gates.append((op, w1, w2, wout))
    return (ins, gates)

class Wire:
    def __init__(self, name):
        self.name = name
        self.connected_to = []
        self.state = None

    def connect(self, gate):
        self.connected_to.append(gate)

    def set(self, state, debug=False):
        if self.state is None:
            if debug: print(f"SET {self.name} TO {state}")
            self.state = state
            self._propagate(debug)
        else:
            raise Exception(f"Wire {self.name} is already set to {self.state!r}, can't set again to {state!r}")

    def _propagate(self, debug):
        for gate in self.connected_to:
            if debug: print(f"  -> {gate!r}")
            gate.check_state(debug)

    def __repr__(self):
        return f"Wire({self.name!r}, targets={self.connected_to!r})"

class Gate:
    def __init__(self, w1, w2, wout):
        self.w1 = w1
        self.w2 = w2
        self.wout = wout
        w1.connect(self)
        w2.connect(self)

    def check_state(self, debug=False):
        if self.w1.state is not None and self.w2.state is not None:
            if debug: print(f"    ==> {self.evaluate()}")
            self.wout.set(self.evaluate())

    def __repr__(self):
        return f"{self.__class__.__name__}({self.w1.name!r}, {self.w2.name!r}, {self.wout.name!r})"

class ANDGate(Gate):
    def evaluate(self):
        return self.w1.state and self.w2.state

class ORGate(Gate):
    def evaluate(self):
        return self.w1.state or self.w2.state

class XORGate(Gate):
    def evaluate(self):
        return self.w1.state ^ self.w2.state

def make_network(parsed_gates):
    wires = {}
    for (op, w1, w2, wout) in parsed_gates:
        wire1 = wires.get(w1, Wire(w1))
        wires.setdefault(w1, wire1)
        wire2 = wires.get(w2, Wire(w2))
        wires.setdefault(w2, wire2)
        wireout = wires.get(wout, Wire(wout))
        wires.setdefault(wout, wireout)
        if op == "AND":
            ANDGate(wire1, wire2, wireout)
        elif op == "OR":
            ORGate(wire1, wire2, wireout)
        elif op == "XOR":
            XORGate(wire1, wire2, wireout)
    return wires

def solvea(raw):
    debug=False
    (ins, parsed_gates) = parse(raw)
    network = make_network(parsed_gates)
    if debug: print(network)
    for (w, v) in ins:
        network[w].set(v, debug=debug)
    acc = 0
    for zwirename in sorted((wname for wname in network if wname.startswith("z")), reverse=True):
        acc <<= 1
        acc |= network[zwirename].state
        if debug: print(f"{zwirename} => {acc}")
    return acc

print("TEST A1 (expect 4)")
print(solvea(test1))
print("TEST A2 (expect 2024)")
print(solvea(test2))
print("SOLVE A")
print(solvea(input_txt))

