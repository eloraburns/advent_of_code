fn main() {
    println!("25a(test; expect 58): {}", solvea("test.txt"));

    println!("25a(input): {}", solvea("input.txt"));
}

#[derive(PartialEq)]
enum C {
    Empty,
    Right,
    Down,
}

fn parse(filename: &str) -> Vec<Vec<C>> {
    let contents = std::fs::read_to_string(filename).unwrap();
    contents.lines()
        .map(|l| {
            l.chars().map(|c| match c {
                '>' => C::Right,
                'v' => C::Down,
                '.' => C::Empty,
                other => panic!("Unknown cell '{}'", other),
            }).collect()
        }).collect()
}

fn solvea(filename: &str) -> usize {
    let mut map = parse(filename);
    let width = map.first().unwrap().len();
    let height = map.len();
    let mut step = 0;
    let mut moved = true;
    while moved {
        moved = false;
        for y in 0..height {
            let mut movers: Vec<usize> = vec![];
            for x in (0..width).rev() {
                if map[y][x] == C::Right && map[y][(x+1)%width] == C::Empty {
                    movers.push(x);
                }
            }
            if !movers.is_empty() {
                moved = true;
            }
            for x in movers {
                map[y][x] = C::Empty;
                map[y][(x+1)%width] = C::Right;
            }
        }
        for x in 0..width {
            let mut movers: Vec<usize> = vec![];
            for y in (0..height).rev() {
                if map[y][x] == C::Down && map[(y+1)%height][x] == C::Empty {
                    movers.push(y);
                }
            }
            if !movers.is_empty() {
                moved = true;
            }
            for y in movers {
                map[y][x] = C::Empty;
                map[(y+1)%height][x] = C::Down;
            }
        }
        step += 1;
    }
    return step;
}