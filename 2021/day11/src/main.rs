use std::collections::HashSet;

fn main() {
    let test = load("test.txt");
    let input = load("input.txt");

    println!("11a(test): {}", solvea(&test));
    println!("11b(test): {}", solveb(&test));

    println!("11a(input): {}", solvea(&input));
    println!("11b(input): {}", solveb(&input));
}

const SIZE: usize = 10;
const STEPS: usize = 100;
const ZERO: u8 = 48;

fn load(filename: &str) -> Vec<Vec<u8>> {
    std::fs::read_to_string(filename)
        .expect("missing file")
        .lines()
        .map(|l| l.bytes().map(|c| c - ZERO).collect())
        .collect()
}

fn solvea(original_map: &Vec<Vec<u8>>) -> usize {
    let mut map = original_map.clone();
    let mut num_flashes = 0;
    for _ in 0..STEPS {
        let mut flashers = HashSet::new();
        for x in 0..SIZE {
            for y in 0..SIZE {
                map[x][y] += 1;
                if map[x][y] == 10 {
                    flashers.insert((x, y));
                }
            }
        }
        let num_flashed: usize = flashers
            .iter()
            .map(|(x, y)| flash(&mut map, *x, *y))
            .sum();

        for x in 0..SIZE {
            for y in 0..SIZE {
                if map[x][y] > 9 {
                    map[x][y] = 0;
                }
            }
        }

        num_flashes += num_flashed;
    }

    return num_flashes;
}

fn solveb(original_map: &Vec<Vec<u8>>) -> usize {
    let mut map = original_map.clone();
    for step in 1.. {
        let mut flashers = HashSet::new();
        for x in 0..SIZE {
            for y in 0..SIZE {
                map[x][y] += 1;
                if map[x][y] == 10 {
                    flashers.insert((x, y));
                }
            }
        }
        let num_flashed: usize = flashers
            .iter()
            .map(|(x, y)| flash(&mut map, *x, *y))
            .sum();

        if num_flashed == (SIZE*SIZE) {
            return step;
        }

        for x in 0..SIZE {
            for y in 0..SIZE {
                if map[x][y] > 9 {
                    map[x][y] = 0;
                }
            }
        }
    }
    return 0;
}

fn flash(map: &mut Vec<Vec<u8>>, x: usize, y: usize) -> usize {
    let mut flashed = 1;
    // TOP
    if x > 0 && y > 0 {
        map[x-1][y-1] += 1;
        if map[x-1][y-1] == 10 {
            flashed += flash(map, x-1, y-1);
        }
    }
    if x > 0 {
        map[x-1][y] += 1;
        if map[x-1][y] == 10 {
            flashed += flash(map, x-1, y);
        }
    }
    if x > 0 && y < (SIZE-1) {
        map[x-1][y+1] += 1;
        if map[x-1][y+1] == 10 {
            flashed += flash(map, x-1, y+1);
        }
    }
    // SIDES
    if y > 0 {
        map[x][y-1] += 1;
        if map[x][y-1] == 10 {
            flashed += flash(map, x, y-1);
        }
    }
    if y < (SIZE-1) {
        map[x][y+1] += 1;
        if map[x][y+1] == 10 {
            flashed += flash(map, x, y+1);
        }
    }
    // BOTTOM
    if x < (SIZE-1) && y > 0 {
        map[x+1][y-1] += 1;
        if map[x+1][y-1] == 10 {
            flashed += flash(map, x+1, y-1);
        }
    }
    if x < (SIZE-1) {
        map[x+1][y] += 1;
        if map[x+1][y] == 10 {
            flashed += flash(map, x+1, y);
        }
    }
    if x < (SIZE-1) && y < (SIZE-1) {
        map[x+1][y+1] += 1;
        if map[x+1][y+1] == 10 {
            flashed += flash(map, x+1, y+1);
        }
    }
     return flashed;
}