use std::collections::HashSet;
use std::fs;

fn main() {
    println!("9a(test): {}", solvea("test.txt"));
    println!("9b(test): {}", solveb("test.txt"));

    println!("9a(input): {}", solvea("input.txt"));
    println!("9b(input): {}", solveb("input.txt"));
}

const ZERO: u8 = 48; // ASCII 0

fn solvea(filename: &str) -> usize {
    let contents: Vec<Vec<u8>> = fs::read_to_string(filename).unwrap()
        .lines()
        .map(|l| l.trim().bytes().map(|c| c - ZERO).collect())
        .collect();
    
    let rows = contents.len();
    let cols = contents.first().unwrap().len();
    let mut risk_acc = 0usize;

    for row in 0..rows {
        for col in 0..cols {
            let here = contents[row][col];
            let mut up = 10u8;
            let mut down = 10u8;
            let mut left = 10u8;
            let mut right = 10u8;
            if col > 0 {
                up = contents[row][col-1];
            }
            if col < (cols - 1) {
                down = contents[row][col+1];
            }
            if row > 0 {
                left = contents[row-1][col];
            }
            if row < (rows - 1) {
                right = contents[row+1][col];
            }
            if here < up && here < down && here < left && here < right {
                risk_acc += (here as usize) + 1;
            }
        }
    }

    risk_acc
}

fn solveb(filename: &str) -> usize {
    let contents: Vec<Vec<u8>> = fs::read_to_string(filename).unwrap()
        .lines()
        .map(|l| l.trim().bytes().map(|c| c - ZERO).collect())
        .collect();
    
    let rows = contents.len();
    let cols = contents.first().unwrap().len();
    let mut low_points: Vec<(usize, usize)> = vec![];

    for row in 0..rows {
        for col in 0..cols {
            let here = contents[row][col];
            let mut up = 10u8;
            let mut down = 10u8;
            let mut left = 10u8;
            let mut right = 10u8;
            if col > 0 {
                up = contents[row][col-1];
            }
            if col < (cols - 1) {
                down = contents[row][col+1];
            }
            if row > 0 {
                left = contents[row-1][col];
            }
            if row < (rows - 1) {
                right = contents[row+1][col];
            }
            if here < up && here < down && here < left && here < right {
                low_points.push((row, col));
            }
        }
    }

    let mut basin_sizes: Vec<_> = low_points
        .iter()
        .map(|(row, col)| basin_size(&contents, *row, *col))
        .collect();
    basin_sizes.sort();
    let bb1 = basin_sizes.pop().unwrap();
    let bb2 = basin_sizes.pop().unwrap();
    let bb3 = basin_sizes.pop().unwrap();
    // low_points.map(basin_size).sort(-).take(3).reduce(*)

    bb1 * bb2 * bb3
}

fn basin_size(map: &Vec<Vec<u8>>, row: usize, col: usize) -> usize {
    let max_row = map.len() - 1;
    let max_col = map.first().unwrap().len() -1 ;
    let mut to_check = vec![(row, col)];
    let mut seen: HashSet<(usize, usize)> = HashSet::new();

    while !to_check.is_empty() {
        let (r, c) = to_check.pop().unwrap();
        if seen.contains(&(r, c)) || map[r][c] == 9 {
            continue;
        } else {
            seen.insert((r, c));
        }
        if 0 < r {
            to_check.push((r - 1, c));
        }
        if r < max_row {
            to_check.push((r + 1, c));
        }
        if 0 < c {
            to_check.push((r, c - 1));
        }
        if c < max_col {
            to_check.push((r, c + 1));
        }
    }

    return seen.len();
}