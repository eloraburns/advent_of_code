use std::collections::HashMap;
use std::collections::HashSet;
use std::fs;

#[derive(Debug)]
struct PartNumber {
    value: u64,
    x1: i64,
    x2: i64,
    y: i64,
}

#[derive(Debug)]
struct Symbol {
    value: char,
    x: i64,
    y: i64,
}

#[derive(Debug)]
#[derive(Eq)]
#[derive(Hash)]
#[derive(PartialEq)]
struct Point {
    x: i64,
    y: i64,
}

fn main() {
    println!("Test a (4361): {}", solvea("testa.txt"));
    println!("Test 1 (0): {}", solvea("test1.txt"));
    println!("Test 2 (42): {}", solvea("test2.txt"));
    println!("Test 3 (42): {}", solvea("test3.txt"));
    println!("Test 4 (42): {}", solvea("test4.txt"));
    println!("Test 5 (42): {}", solvea("test5.txt"));
    println!("Test 6 (42): {}", solvea("test6.txt"));
    println!("Test 7 (0): {}", solvea("test7.txt"));
    // 518022 is too high
    // 514969 is just right
    println!("Solve a (514969): {}", solvea("input.txt"));

    println!("Test b (467835): {}", solveb("testa.txt"));
    println!("Test 8 (12): {}", solveb("test8.txt"));
    println!("Test 9 (0): {}", solveb("test9.txt"));
    println!("Solve b: {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> u64 {
    let (parts, symbols) = parse(filename);
    let valids: HashSet<Point> = symbols.iter().flat_map(|s|
        points_around(s.x, s.y)
    ).collect();

    // println!("{:?}\n{:?}\n{:?}", parts, symbols, valids);
    let sum_of_valid_parts: u64 = parts.iter().filter_map(|p| {
        if (p.x1..(p.x2+1)).any(|x| valids.contains(&Point {x, y: p.y})) {
            Some(p.value)
        } else {
            None
        }
    }).sum();

    // println!("{} parts, {} symbols, {} valids", parts.len(), symbols.len(), valids.len());
    sum_of_valid_parts
}

fn solveb(filename: &str) -> u64 {
    let (parts, symbols) = parse(filename);
    let parts_by_id: HashMap<Point, &PartNumber> = parts.iter().map(|p|
        (Point { x: p.x1, y: p.y }, p)
    ).collect();
    let parts_by_point: HashMap<Point, &Point> = parts_by_id.iter().flat_map(|(c, p)|
        (p.x1..(p.x2+1)).map(|px|
            (Point { x: px, y: p.y }, c)
        ).collect::<Vec<(Point, &Point)>>()
    ).collect();

    symbols.iter().filter(|s|
        s.value == '*'
    ).map(|s|
        points_around(s.x, s.y).iter().filter_map(|p|
            parts_by_point.get(&p)
        ).collect::<HashSet<_>>()
    ).filter(|ids|
        ids.len() == 2
    ).map(|ids|
        ids.iter().fold(1, |acc, partid| acc*parts_by_id[partid].value)
    ).sum()
}

fn points_around(s_x: i64, s_y: i64) -> Vec<Point> {
    vec![
        Point { x: s_x-1, y: s_y-1 },
        Point { x: s_x-1, y: s_y   },
        Point { x: s_x-1, y: s_y+1 },
        Point { x: s_x  , y: s_y-1 },
        Point { x: s_x  , y: s_y+1 },
        Point { x: s_x+1, y: s_y-1 },
        Point { x: s_x+1, y: s_y   },
        Point { x: s_x+1, y: s_y+1 },
    ]
}

fn parse(filename: &str) -> (Vec<PartNumber>, Vec<Symbol>) {
    let contents = fs::read_to_string(filename).expect("can't read file");
    let mut parts: Vec<PartNumber> = Vec::new();
    let mut symbols: Vec<Symbol> = Vec::new();
    let mut in_part: bool;
    let mut this_part: u64 = 0;
    let mut this_part_x1: i64 = 0;
    let mut last_seen_x: i64 = 0;

    for (y, l) in contents.lines().enumerate() {
        in_part = false;
        for (x, c) in l.chars().enumerate() {
            last_seen_x = x as i64;
            if in_part {
                match c {
                    '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' => {
                        this_part = this_part * 10 + c.to_digit(10).unwrap() as u64;
                    },
                     _ => {
                        in_part = false;
                        parts.push(PartNumber {
                            value: this_part,
                            x1: this_part_x1,
                            x2: x as i64 - 1,
                            y: y as i64
                        });
                        if c != '.' {
                            symbols.push(Symbol {
                                value: c,
                                x: x as i64,
                                y: y as i64
                            });
                        };
                     },
                }
            } else {
                match c {
                    '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' => {
                        in_part = true;
                        this_part = c.to_digit(10).unwrap() as u64;
                        this_part_x1 = x as i64;
                    },
                    '.' => (),
                    _ =>
                        symbols.push(Symbol {
                            value: c,
                            x: x as i64,
                            y: y as i64
                        }),
                }
            }
        }
        if in_part {
            parts.push(PartNumber {
                value: this_part,
                x1: this_part_x1,
                x2: last_seen_x,
                y: y as i64
            });
        }
    }

    (parts, symbols)
}
