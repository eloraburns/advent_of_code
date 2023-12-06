use std::fs;
use std::iter::zip;

fn main() {
    println!("Test a (288): {}", solvea("testa.txt"));
    println!("Solve a (1624896): {}", solvea("input.txt"));
    println!("Test b (71503): {}", solveb("testa.txt"));
    println!("Solve b (32583852): {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> u64 {
    let rounds = parse(filename);
    rounds.iter().fold(1, |acc, r| num_wins(*r) * acc)
}

fn num_wins((time, distance): (u64, u64)) -> u64 {
    (1..time).map(|x|
        if (time - x) * x > distance {
            1
        } else {
            0
        }
    ).sum()
}

fn solveb(filename: &str) -> u64 {
    let (time, distance) = parseb(filename);
    num_wins((time, distance))
}

fn parse_ints(l: &str) -> Vec<u64> {
    let mut words = l.split_whitespace();
    words.next();
    words.map(|n| n.parse::<u64>().unwrap()).collect()
}

fn parse(filename: &str) -> Vec<(u64, u64)> {
    let contents = fs::read_to_string(filename).expect("can't read file");

    let mut lines = contents.lines();
    let times = parse_ints(lines.next().unwrap());
    let distances = parse_ints(lines.next().unwrap());

    zip(times, distances).collect()
}

fn parseb_ints(l: &str) -> u64 {
    let mut words = l.split(":");
    words.next();
    let actual = words.next().unwrap();
    actual.replace(" ", "").parse::<u64>().unwrap()
}

fn parseb(filename: &str) -> (u64, u64) {
    let contents = fs::read_to_string(filename).expect("can't read file");

    let mut lines = contents.lines();
    let times = parseb_ints(lines.next().unwrap());
    let distances = parseb_ints(lines.next().unwrap());

    (times, distances)
}
