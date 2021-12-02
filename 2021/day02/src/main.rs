use std::fs;

enum Cmd {
    Forward,
    Up,
    Down,
}

fn main() {
    let contents = fs::read_to_string("input.txt")
        .expect("can't read file");

    let dirs: Vec<(Cmd,i32)> = contents.lines()
        .map(|l| {
            let mut parts = l.split_whitespace();
            let dir_str = parts.next().unwrap();
            let amt: i32 = parts.next().unwrap().parse().unwrap();
            match dir_str {
                "forward" => (Cmd::Forward, amt),
                "up" => (Cmd::Up, amt),
                "down" => (Cmd::Down, amt),
                _ => panic!("unknown command {}", dir_str)
            }
        })
        .collect();

    println!("2a: {}", solve2a(&dirs));
    println!("2b: {}", solve2b(&dirs));

}

fn solve2a(dirs: &Vec<(Cmd, i32)>) -> i32 {
    let mut x: i32 = 0;
    let mut y: i32 = 0;
    for (c, a) in dirs {
        match c {
            Cmd::Forward => x += a,
            Cmd::Up => y -= a,
            Cmd::Down => y += a,
        }
    }
    return x * y;
}

fn solve2b(dirs: &Vec<(Cmd, i32)>) -> i32 {
    let mut x: i32 = 0;
    let mut y: i32 = 0;
    let mut angle: i32 = 0;
    for (c, a) in dirs {
        match c {
            Cmd::Forward => {
                x += a;
                y += angle * a;
            },
            Cmd::Up => angle -= a,
            Cmd::Down => angle += a,
        }
    }
    return x * y;
}