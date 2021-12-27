fn main() {
    // 94992994195998
    println!("24a: {:?}", solvea("seriala.txt"));
    println!("24b: {:?}", solvea("serialb.txt"));
}

#[derive(Debug)]
enum Arg {
    X,
    Y,
    Z,
    W,
    N(i64),
}

#[derive(Debug)]
enum Op {
    Inp(Arg),
    Add(Arg, Arg),
    Mul(Arg, Arg),
    Div(Arg, Arg),
    Mod(Arg, Arg),
    Eql(Arg, Arg),
}

fn read_serial(filename: &str) -> Vec<i64> {
    let contents = std::fs::read_to_string(filename).unwrap();
    contents
        .trim()
        .as_bytes()
        .iter()
        .map(|b| (b - 48) as i64)
        .collect()
}

fn solvea(serial_name: &str) -> Vec<i64> {
    let prog = parse("input.txt");
    let inp = read_serial(serial_name);
    // let v = vec![9,9,9,6,2,9,9,4,9,9,5,1,1,1];
    //           >                         <
    //             >                     <
    //               >                 <
    //                 >         < > <
    //                 6 > < > < 9 9 5
    //                   2 9 9 4
    if eval(&prog, &inp) {
        return inp
    }
    // for i in 1..10 {
    //     let input: Vec<i64> = vec![i; 14];
    //     println!("Trying {:?}", input);
    //     if eval(&prog, &input) {
    //         return input
    //     }
    // }
    vec![0; 14]
}

fn parse(filename: &str) -> Vec<Op> {
    let contents = std::fs::read_to_string(filename).unwrap();
    contents
        .lines()
        .map(
            |l| {
                match &l[0..3] {
                    "inp" => Op::Inp(l2a(&l[4..5])),
                    "add" => Op::Add(l2a(&l[4..5]), l2a(&l[6..])),
                    "mul" => Op::Mul(l2a(&l[4..5]), l2a(&l[6..])),
                    "div" => Op::Div(l2a(&l[4..5]), l2a(&l[6..])),
                    "mod" => Op::Mod(l2a(&l[4..5]), l2a(&l[6..])),
                    "eql" => Op::Eql(l2a(&l[4..5]), l2a(&l[6..])),
                    unknown => panic!("Unknown operation {:?}", unknown),
                }
        })
        .collect()
}

fn l2a(letter: &str) -> Arg {
    match letter {
        "x" => Arg::X,
        "y" => Arg::Y,
        "z" => Arg::Z,
        "w" => Arg::W,
        number => Arg::N(number.parse().expect("couldn't parse number arg")),
    }
}

fn debug_z(z: i64) -> String {
    let mut digits = vec![];
    let mut myz = z;
    while myz > 0 {
        digits.push(myz % 26);
        myz /= 26;
    }
    digits.reverse();
    format!("{:?}", digits)
}

fn eval(program: &Vec<Op>, inputs: &Vec<i64>) -> bool {
    assert_eq!(inputs.len(), 14);
    let (mut x, mut y, mut z, mut w) = (0i64, 0i64, 0i64, 0i64);
    let mut ins = inputs.iter();
    println!("{:?}", inputs);
    for op in program {
        // println!("x={}, y={}, z={} ({}), w={}, {:?}", x, y, z, debug_z(z), w, op);
        match op {
            Op::Inp(arg) => {
                println!("{}", debug_z(z));
                match arg {
                    Arg::X => x = *ins.next().unwrap(),
                    Arg::Y => y = *ins.next().unwrap(),
                    Arg::Z => z = *ins.next().unwrap(),
                    Arg::W => w = *ins.next().unwrap(),
                    Arg::N(_) => panic!("Unexpected number argument to INP"),
                }
            },
            Op::Add(arg1, arg2) => {
                let arg2_val = match arg2 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                match arg1 {
                    Arg::X => x += arg2_val,
                    Arg::Y => y += arg2_val,
                    Arg::Z => z += arg2_val,
                    Arg::W => w += arg2_val,
                    Arg::N(_) => panic!("Cannot add to a constant"),
                }
            },
            Op::Mul(arg1, arg2) => {
                let arg2_val = match arg2 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                match arg1 {
                    Arg::X => x *= arg2_val,
                    Arg::Y => y *= arg2_val,
                    Arg::Z => z *= arg2_val,
                    Arg::W => w *= arg2_val,
                    Arg::N(_) => panic!("Cannot mul to a constant"),
                }
            },
            Op::Div(arg1, arg2) => {
                let arg2_val = match arg2 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                match arg1 {
                    Arg::X => x /= arg2_val,
                    Arg::Y => y /= arg2_val,
                    Arg::Z => z /= arg2_val,
                    Arg::W => w /= arg2_val,
                    Arg::N(_) => panic!("Cannot div to a constant"),
                }
            },
            Op::Mod(arg1, arg2) => {
                let arg2_val = match arg2 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                match arg1 {
                    Arg::X => x %= arg2_val,
                    Arg::Y => y %= arg2_val,
                    Arg::Z => z %= arg2_val,
                    Arg::W => w %= arg2_val,
                    Arg::N(_) => panic!("Cannot mod to a constant"),
                }
            },
            Op::Eql(arg1, arg2) => {
                let arg1_val = match arg1 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                let arg2_val = match arg2 {
                    Arg::X => x, Arg::Y => y, Arg::Z => z, Arg::W => w,
                    Arg::N(n) => *n,
                };
                match arg1 {
                    Arg::X => x = (arg1_val == arg2_val) as i64,
                    Arg::Y => y = (arg1_val == arg2_val) as i64,
                    Arg::Z => z = (arg1_val == arg2_val) as i64,
                    Arg::W => w = (arg1_val == arg2_val) as i64,
                    Arg::N(_) => panic!("Cannot eql to a constant"),
                }
            },
        }
    }
    // println!("x={}, y={}, z={} ({}), w={}", x, y, z, debug_z(z), w);
    println!("{}", debug_z(z));
    z == 0
}