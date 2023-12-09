use std::fs;

fn main() {
    println!("Test a (114): {}", solvea("testa.txt"));
    println!("Solve a (1696140818): {}", solvea("input.txt"));
    println!("Test b (2): {}", solveb("testa.txt"));
    println!("Solve b (1152): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> Vec<Vec<i64>> {
    let contents = fs::read_to_string(filename).expect("can't read file");
    contents.lines().map(|l|
        l.split_whitespace().map(|n| n.parse::<i64>().unwrap()).collect()
    ).collect()
}

fn derivative(seq: &Vec<i64>) -> Vec<i64> {
    let a = seq.iter();
    let b = seq.iter().skip(1);
    a.zip(b).map(|(x, y)| y - x).collect()
}

fn extrapolate(seq: &Vec<i64>) -> (i64,i64) {
    let mut derivs: Vec<Vec<i64>> = vec![];
    let mut this_seq: Vec<i64> = seq.clone();
    while !this_seq.iter().all(|n| *n == 0) {
        derivs.push(this_seq.clone());
        this_seq = derivative(&this_seq);
    }
    derivs.push(this_seq.clone());
    //println!("derivs: {:?}", derivs);
    _ = vec![
        // seq_i   =            0  1  2  3
        /* deriv_i = 0 */ vec![ 1, 2, 3, 4 ], //acc=5
        /* deriv_i = 0 */ vec![ 1, 1, 1], //acc=1
        /* deriv_i = 0 */ vec![ 0, 0 ], //acc=0
    ];
    let mut accf = 0;
    let mut accb = 0;
    for i in 1..derivs.len() {
        // derivs.len = 3
        // seq_len = 4
        // i = 1, deriv_i = 1, seq_i = 2
        // i = 2, deriv_i = 0, seq_i = 3
        let deriv_i = derivs.len() - 1 - i;
        let seq_i = seq.len() - 1 - deriv_i;
        //println!("{}: {:?}", i, seq);
        accf = accf + derivs[deriv_i][seq_i];
        accb = derivs[deriv_i][0] - accb;
    }
    (accb, accf)
}

fn solvea(filename: &str) -> i64 {
    let sequences = parse(filename);
    //println!("{:?} => {:?}", sequences[0], extrapolate(&sequences[0]));
    sequences.iter().map(|s| extrapolate(s).1 ).collect::<Vec<i64>>().iter().sum()
}

fn solveb(filename: &str) -> i64 {
    let sequences = parse(filename);
    sequences.iter().map(|s| extrapolate(s).0 ).collect::<Vec<i64>>().iter().sum()
}
