use std::collections::HashMap;
use std::fs;

fn main() {
    println!("8a(test): {}", solvea("test.txt"));
    println!("8b(test): {}", solveb("test.txt"));

    println!("8a(test): {}", solvea("test.txt"));
    println!("8b(input): {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> usize {
    std::fs::read_to_string(filename)
        .expect("can't read input file")
        .lines()
        .flat_map(|l| {
            let mut halves = l.split(" | ");
            let _examples = halves.next().unwrap();
            let four_digits: Vec<&str> = halves.next().unwrap()
                .split(" ")
                .collect();
            four_digits
        })
        .filter(|d: &&str| match d.len() {
            2 => true,
            3 => true,
            4 => true,
            7 => true,
            _ => false,
        })
        .count()
}

fn solveb(filename: &str) -> u32 {
    std::fs::read_to_string(filename)
        .expect("can't read input file")
        .lines()
        .map(|l| {
            let mut halves = l.split(" | ");
            let examples: Vec<u8> = adigs2u8digs(halves.next().unwrap());
            let four_digits: Vec<u8> = adigs2u8digs(halves.next().unwrap());
            let map = divinate(examples);
            evaluate(&map, four_digits)
        })
        .sum()
}

fn evaluate_digit(map: &Vec<(u8, u8)>, dig: u8) -> u32 {
    for (k, v) in map {
        if *k == dig {
            return *v as u32;
        }
    }
    return 999;
}

fn evaluate(map: &Vec<(u8, u8)>, num: Vec<u8>) -> u32 {
    let val: u32 = vec![1000, 100, 10, 1]
        .iter()
        .zip(num.iter())
        .map(|(place_value, digit)| place_value * evaluate_digit(map, *digit))
        .sum();

    return val;
}

fn divinate(examples: Vec<u8>) -> Vec<(u8, u8)> {
    let mut one = 0u8;
    let mut four = 0u8;

    // Find the well-known digits
    let mut map: Vec<(u8, u8)> = examples
        .iter()
        .flat_map(|d|
            match pop(*d) {
                2 => {
                    one = *d;
                    vec![(*d, 1)]
                },
                3 => {
                    vec![(*d, 7)]
                },
                4 => {
                    four = *d;
                    vec![(*d, 4)]
                },
                7 => {
                    vec![(*d, 8)]
                },
                _ => vec![],
            }
        )
        .collect();

    // Divine the rest
    examples.iter().for_each(|d|
        match pop(*d) {
            6 => {
                if pop(d & !one) == 5 {
                    map.push((*d, 6));
                } else if pop(d & !(four - one)) == 5 {
                    map.push((*d, 0));
                } else {
                    map.push((*d, 9));
                }
            },
            5 => {
                if pop(d & !one) == 3 {
                    map.push((*d, 3));
                } else if pop(d & !(four - one)) == 3 {
                    map.push((*d, 5));
                } else {
                    map.push((*d, 2));
                }
            },
            _ => (),

        }
    );
    map
}

fn pop(x: u8) -> u8 {
    let mut count = 0;
    for i in 0..7 {
        count += (x & (1 << i)) >> i;
    }
    // println!("pop {} = {}", x, count);
    count
}

fn adigs2u8digs(adigs: &str) -> Vec<u8> {
    adigs.split(" ").map(a2b).collect()
}

const BASE: u8 = 97;

fn a2b(a: &str) -> u8 {
    let mut out: u8 = 0;
    for c in a.bytes() {
        out |= 1 << (c - BASE);
    }
    out
}