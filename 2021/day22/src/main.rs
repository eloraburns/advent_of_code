use std::ops::Range;
use std::collections::HashSet;
use regex::Regex;

fn main() {
    println!("22a(test; expect 590784): {}", solvea("test.txt"));

    println!("22a(input): {}", solvea("input.txt"));
}

fn parse(filename: &str) -> Vec<(bool, Range<i32>, Range<i32>, Range<i32>)> {
    let input = std::fs::read_to_string(filename).unwrap();
    let re = Regex::new(r"(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)")
        .unwrap();
    input
        .lines()
        .map(|l| {
            let cap = re.captures(l).unwrap();
            (
                if cap[1] == *"on" { true } else { false },
                cap[2].parse().unwrap()..(cap[3].parse::<i32>().unwrap()+1),
                cap[4].parse().unwrap()..(cap[5].parse::<i32>().unwrap()+1),
                cap[6].parse().unwrap()..(cap[7].parse::<i32>().unwrap()+1)
            )
        })
        .collect()
}

fn solvea(filename: &str) -> usize {
    let prog = parse(filename);
    let mut reactor: HashSet<(i32, i32, i32)> = HashSet::new();
    for (o, xr, yr, zr) in prog {
        if xr.start > 50 || xr.end < -50
        || yr.start > 50 || yr.end < -50
        || zr.start > 50 || zr.end < -50 {
            continue;
        }
        for x in xr.clone() {
            for y in yr.clone() {
                for z in zr.clone() {
                    if o {
                        reactor.insert((x, y, z));
                    } else {
                        reactor.remove(&(x, y, z));
                    }
                }
            }
        }
    }

    return reactor.len();
}