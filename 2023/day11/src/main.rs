use std::fs;

fn main() {
    println!("Test a (374): {}", solvea("testa.txt"));
    println!("Solve a (10173804): {}", solvea("input.txt"));
    println!("Test b-10 (1030): {}", solve("testa.txt", 9));
    println!("Test b-100 (8410): {}", solve("testa.txt", 99));
    println!("Solve b (634324905172): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> Vec<Vec<char>> {
    let contents = fs::read_to_string(filename).expect("can't read file");
    contents.lines().map(|l| l.chars().collect()).collect()
}

fn solve(filename: &str, expansion: i64) -> i64 {
    let universe = parse(filename);
    let mut acc = 0;
    let row_offsets: Vec<_> = universe.iter().map(|row| {
        if row.iter().all(|c| *c == '.') {
            acc += expansion;
        }
        acc
    }).collect();
    acc = 0;
    let col_offsets: Vec<_> = (0..universe[0].len()).map(|x| {
        if universe.iter().map(|row| row[x]).all(|c| c == '.') {
            acc += expansion;
        }
        acc
    }).collect();
    let galaxies: Vec<_> = universe.iter().enumerate().flat_map(|(y, row)|
        row.iter().enumerate().filter_map(|(x, c)|
            if *c == '#' {
                Some((x, y))
            } else {
                None
            }
        ).collect::<Vec<_>>()
    ).collect();
    //println!("row_offsets: {:?}", row_offsets);
    //println!("col_offsets: {:?}", col_offsets);

    let mut acc = 0;
    for i in 0..(galaxies.len() - 1) {
        for j in (i+1)..galaxies.len() {
            //println!("(i,j) = ({},{})", i, j);
            let x1 = galaxies[i].0 as i64;
            let y1 = galaxies[i].1 as i64;
            let x2 = galaxies[j].0 as i64;
            let y2 = galaxies[j].1 as i64;

            acc +=
                ((x1+col_offsets[x1 as usize]) - (x2+col_offsets[x2 as usize])).abs()
                +
                ((y1+row_offsets[y1 as usize]) - (y2+row_offsets[y2 as usize])).abs();
        }
    }
    acc
}

fn solvea(filename: &str) -> i64 {
    solve(filename, 1)
}

fn solveb(filename: &str) -> i64 {
    solve(filename, 1000000-1)
}
