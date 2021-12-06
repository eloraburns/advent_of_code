use std::collections::HashMap;
use std::fs;

fn main() {
    solvea("test.txt");
    solveb("test.txt");

    solvea("input.txt");
    solveb("input.txt");
}

fn solvea(filename: &str) {
    let contents = fs::read_to_string(filename).expect("Couldn't read file");

    let lines: Vec<(i32, i32, i32, i32)> = contents.lines()
        .map(|l| {
            let coords: Vec<i32> = l
                .trim()
                .split(" -> ")
                .flat_map(|c| -> Vec<i32> {
                    let mut x = c.split(",");
                    return vec!(
                        x.next().unwrap().parse().unwrap(),
                        x.next().unwrap().parse().unwrap(),
                    );
                })
                .collect();
            return (coords[0], coords[1], coords[2], coords[3]);
        })
        .collect();

    let spots: Vec<(i32, i32)> = lines.iter()
        .flat_map(|(x1, y1, x2, y2)|
            if x1 == x2 {
                if y1 < y2 {
                    (*y1..(y2+1)).map(|y| (*x1, y)).collect()
                } else {
                    (*y2..(y1+1)).map(|y| (*x1, y)).collect()
                }
            } else if y1 == y2 {
                if x1 < x2 {
                    (*x1..(x2+1)).map(|x| (x, *y1)).collect()
                } else {
                    (*x2..(x1+1)).map(|x| (x, *y1)).collect()
                }
            } else {
                return vec!();
            }
        )
        .collect();
    
    let mut undersea_map = HashMap::new();
    for spot in spots {
        *undersea_map.entry(spot).or_insert(0) += 1;
    }

    let num_intersections = undersea_map
        .values()
        .filter(|v| **v >= 2)
        .count();

    // 4791 is too high
    // 4745 is correct!
    println!("5a({}): {}", filename, num_intersections);
}

fn solveb(filename: &str) {
    let contents = fs::read_to_string(filename).expect("Couldn't read file");

    let lines: Vec<(i32, i32, i32, i32)> = contents.lines()
        .map(|l| {
            let coords: Vec<i32> = l
                .trim()
                .split(" -> ")
                .flat_map(|c| -> Vec<i32> {
                    let mut x = c.split(",");
                    return vec!(
                        x.next().unwrap().parse().unwrap(),
                        x.next().unwrap().parse().unwrap(),
                    );
                })
                .collect();
            return (coords[0], coords[1], coords[2], coords[3]);
        })
        .collect();

    let spots: Vec<(i32, i32)> = lines.iter()
        .flat_map(|(x1, y1, x2, y2)| {
            if x1 == x2 && y1 < y2 {
                (*y1..(y2+1)).map(|y| (*x1, y)).collect()
            } else if x1 == x2 && y1 > y2 {
                (*y2..(y1+1)).map(|y| (*x1, y)).collect()
            } else if y1 == y2 && x1 < x2{
                (*x1..(x2+1)).map(|x| (x, *y1)).collect()
            } else if y1 == y2 && x1 > x2{
                (*x2..(x1+1)).map(|x| (x, *y1)).collect()
            } else if x1 < x2 && y1 < y2 {
                (0..(x2 - x1 + 1)).map(|i| (*x1 + i, *y1 + i)).collect()
            } else if x1 < x2 && y1 > y2 {
                (0..(x2 - x1 + 1)).map(|i| (*x1 + i, *y1 - i)).collect()
            } else if x1 > x2 && y1 < y2 {
                (0..(x1 - x2 + 1)).map(|i| (*x1 - i, *y1 + i)).collect()
            } else if x1 > x2 && y1 > y2 {
                (0..(x1 - x2 + 1)).map(|i| (*x1 - i, *y1 - i)).collect()
            } else {
                panic!("What kind of points did you give me!?");
                vec!()
            }
        })
        .collect();
    
    let mut undersea_map = HashMap::new();
    for spot in spots {
        *undersea_map.entry(spot).or_insert(0) += 1;
    }

    let num_intersections = undersea_map
        .values()
        .filter(|v| **v >= 2)
        .count();

    println!("5b({}): {}", filename, num_intersections);
}
