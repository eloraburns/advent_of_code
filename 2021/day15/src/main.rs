const ZERO: u8 = 48;

fn main() {
    println!("15a(test), expect 40: {}", solvea("test.txt"));

    // 697 is too high
    println!("15a(input): {}", solvea("input.txt"));
}

fn parse(filename: &str) -> Vec<Vec<usize>> {
    std::fs::read_to_string(filename)
        .unwrap()
        .lines()
        .map(|l| {
            l.bytes().map(|b| (b - ZERO) as usize).collect()
        } )
        .collect()
}

#[derive(Copy,Clone)]
struct HeapNode {
    x: usize,
    y: usize,
    cost: usize,
}
type Heap = Vec<HeapNode>;

fn heap_new() -> Heap {
    vec![]
}

fn heap_push(heap: &mut Heap, node: HeapNode) {
    let i = heap.len();
    heap.push(node);
    heap_bub_up(heap, i);
}

fn heap_bub_up(heap: &mut Heap, index: usize) {
    let mut i = index;
    while i > 0 {
        let parent = i >> 1;
        if heap[parent].cost > heap[i].cost {
            heap_swap(heap, parent, i);
        }
        i = parent;
    }
}

fn heap_bub_down(heap: &mut Heap, index: usize) {
    let mut i = index;
    loop {
        let l = i << 1;
        if l >= heap_len(heap) {
            break;
        }
        let r = l + 1;
        if r >= heap_len(heap) {
            // handle l only
            if heap[i].cost > heap[l].cost {
                heap_swap(heap, i, l);
            }
            // Because there was only an l leaf, we are definitely at the bottom,
            // so immediately break, we're done here.
            break;
        } else {
            // handle l and r
            if heap[l].cost < heap[r].cost {
                if heap[l].cost < heap[i].cost {
                    heap_swap(heap, i, l);
                }
                i = l;
            } else {
                if heap[r].cost < heap[i].cost {
                    heap_swap(heap, i, r);
                }
                i = r;
            }
        }
    }
}

fn heap_len(heap: &Heap) -> usize {
    heap.len()
}

fn heap_swap(heap: &mut Heap, i: usize, j: usize) {
    let t = heap[i];
    heap[i] = heap[j];
    heap[j] = t;
}

fn heap_pop(heap: &mut Heap) -> HeapNode {
    let retval = heap[0];
    heap[0] = heap.pop().unwrap();
    heap_bub_down(heap, 0);
    retval
}

fn heap_update(heap: &mut Heap, node: &HeapNode) {
    for i in 0..heap.len() {
        if node.x == heap[i].x && node.y == heap[i].y {
            heap[i].cost = node.cost;
            if i > 0 && heap[i >> 1].cost > heap[i].cost {
                heap_bub_up(heap, i);
            } else {
                heap_bub_down(heap, i);
            }
            break;
        }
    }
}

fn solvea(filename: &str) -> usize {
    let cave = parse(filename);
    let width = cave.first().unwrap().len();
    let height = cave.len();

    let mut unseen = heap_new();
    let mut sssp = vec![vec![width*height*10 as usize; width]; height];
    sssp[0][0] = 0;

    // walk(&cave, &mut sssp, 0, 0, width-1, height-1);

    return sssp[height-1][width-1];
}
