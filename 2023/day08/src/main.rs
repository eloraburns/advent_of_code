use std::collections::HashMap;
use std::fs;

fn main() {
    println!("Test a (2): {}", solvea("test-2.txt"));
    println!("Test a (6): {}", solvea("test-6.txt"));
    println!("Solve a (13207): {}", solvea("input.txt"));
    println!("Test b (6): {}", solveb("testb-6.txt"));
    println!("Solve b (12324145107121): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> (Vec<char>, HashMap<String, (String, String)>) {
    let contents = fs::read_to_string(filename).expect("can't read file");
    let mut lines = contents.lines();
    let directions = lines.next().unwrap().chars().collect();
    lines.next();
    
    (
        directions,
        lines.map(|l| {
            (l[0..3].to_string(), (l[7..10].to_string(), l[12..15].to_string()))
        }).collect()
    )
}

fn solvea(filename: &str) -> u64 {
    let (directions, network) = parse(filename);
    let mut steps = 0;
    let mut here = "AAA".to_string();
    for d in directions.iter().cycle() {
        if here == "ZZZ" {
            break;
        };
        let next = network.get(&here).unwrap();
        here = match d {
            'L' => next.0.to_string(),
            'R' => next.1.to_string(),
            c => panic!("Unexpected turning direction {:?}", c),
        };
        steps += 1;
    };
    steps
}

fn solveb(filename: &str) -> u64 {
    let (directions, network) = parse(filename);
    let mut steps = 0;
    let mut heres: Vec<_> = network.keys().filter(|k|
        k.chars().nth(2) == Some('A')
    ).map(|k| k.to_string()).collect();

    let quicksolves: Vec<u64> = heres.iter().map(|h| {
        let mut hsteps = 0;
        let mut here: String = h.clone();
        for d in directions.iter().cycle() {
            if here.chars().nth(2) == Some('Z') {
                break;
            }
            let next = network.get(&here).unwrap();
            here = match d {
                'L' => next.0.to_string(),
                'R' => next.1.to_string(),
                c => panic!("Unexpected turning direction {:?}", c),
            };
            hsteps += 1;
        }
        hsteps
    }).collect();
    let mut lcp = quicksolves[0];
    for i in 1..quicksolves.len() {
        lcp = lcm(lcp, quicksolves[i]);
    }
    //*quicksolves.iter().reduce(|a, b| &lcm(*a, *b)).unwrap()
    lcp
    //println!("Solveb quicksolves: {:?}", quicksolves);
    //for d in directions.iter().cycle() {
    //    if heres.iter().all(|k|
    //        k.chars().nth(2) == Some('Z')
    //    ) {
    //        break;
    //    };
    //    match d {
    //        'L' => {
    //            heres = heres.iter().map(|k|
    //                network.get(k).unwrap().0.to_string()
    //            ).collect();
    //        },
    //        'R' => {
    //            heres = heres.iter().map(|k|
    //                network.get(k).unwrap().1.to_string()
    //            ).collect();
    //        },
    //        c => panic!("Unexpected turning direction {:?}", c),
    //    };
    //    steps += 1
    //}

    //steps
}

fn lcm(a: u64, b: u64) -> u64 {
    let (mut a2, mut b2) = (a, b);
    while a2 != b2 {
        if a2 < b2 {
            a2 += a;
        } else {
            b2 += b;
        }
    }
    a2
}

#[test]
fn test_lcm() {
    assert_eq!(1, lcm(1, 1));
    assert_eq!(2, lcm(1, 2));
    assert_eq!(2, lcm(2, 1));
    assert_eq!(6, lcm(2, 3));
    assert_eq!(6, lcm(3, 2));
    assert_eq!(30, lcm(10, 15));
    assert_eq!(30, lcm(15, 10));
}
