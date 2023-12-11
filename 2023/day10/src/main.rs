use std::collections::HashSet;
use std::fs;


#[derive(Clone,Debug)]
enum Dir {
    Up,
    Right,
    Down,
    Left,
}

#[derive(Debug)]
struct Turtle {
    x: usize,
    y: usize,
    steps: usize,
    direction: Dir,
    seen: HashSet<(usize, usize)>,
}

type Pipes = Vec<Vec<char>>;

impl Turtle {
    fn new(x: usize, y: usize, direction: &Dir) -> Turtle {
        Turtle { x, y,
            steps: 0,
            direction: direction.clone(),
            seen: [(x, y)].into_iter().collect(),
        }
    }

    fn do_move(&mut self, pipes: &Pipes) -> bool {
        let success = match self.direction {
            Dir::Up =>
                if self.y > 0 { match pipes[self.y-1][self.x] {
                    '|' => {
                        self.y -= 1;
                        true
                    },
                    '7' => {
                        self.y -= 1;
                        self.direction = Dir::Left;
                        true
                    },
                    'F' => {
                        self.y -= 1;
                        self.direction = Dir::Right;
                        true
                    },
                    _ => false
                }} else { false },
            Dir::Right =>
                if self.x < pipes[0].len() - 1 { match pipes[self.y][self.x+1] {
                    '-' => {
                        self.x += 1;
                        true
                    },
                    '7' => {
                        self.x += 1;
                        self.direction = Dir::Down;
                        true
                    },
                    'J' => {
                        self.x += 1;
                        self.direction = Dir::Up;
                        true
                    },
                    _ => false
                }} else { false },
            Dir::Down =>
                if self.y < pipes.len() - 1 { match pipes[self.y+1][self.x] {
                    '|' => {
                        self.y += 1;
                        true
                    },
                    'J' => {
                        self.y += 1;
                        self.direction = Dir::Left;
                        true
                    },
                    'L' => {
                        self.y += 1;
                        self.direction = Dir::Right;
                        true
                    },
                    _ => false
                }} else { false },
            Dir::Left =>
                if self.x > 0 { match pipes[self.y][self.x-1] {
                    '-' => {
                        self.x -= 1;
                        true
                    },
                    'L' => {
                        self.x -= 1;
                        self.direction = Dir::Up;
                        true
                    },
                    'F' => {
                        self.x -= 1;
                        self.direction = Dir::Down;
                        true
                    },
                    _ => false
                }} else { false },
        };
        if success {
            self.steps += 1;
            self.seen.insert((self.x, self.y));
        };
        success
    }
}

fn main() {
    println!("Test a (8): {}", solvea("testa.txt"));
    println!("Solve a (6800): {}", solvea("input.txt"));
    println!("Test b (4): {}", solveb("test-4.txt"));
    println!("Test b (8): {}", solveb("test-8.txt"));
    println!("Test b (10): {}", solveb("test-10.txt"));
    println!("Solve b (483): {}", solveb("input.txt"));
}

fn start_turts(sx: usize, sy: usize, pipes: &Pipes) -> (Turtle, Turtle) {
    let mut turtles = [
        Dir::Up,
        Dir::Right,
        Dir::Down,
        Dir::Left,
    ].iter().filter_map(|dir| {
        let mut t = Turtle::new(sx, sy, dir);
        if t.do_move(&pipes) {
            Some(t)
        } else {
            None
        }
    });
    (turtles.next().unwrap(), turtles.next().unwrap())
}

fn solvea(filename: &str) -> usize {
    let (sx, sy, pipes) = parse(filename);
    //println!("{:?}", pipes);
    let (mut t1, mut t2) = start_turts(sx, sy, &pipes);
    //dump(&vec![&t1, &t2], &pipes);
    while t1.x != t2.x || t1.y != t2.y {
        assert!(t1.do_move(&pipes));
        assert!(t2.do_move(&pipes));
        //dump(&vec![&t1, &t2], &pipes);
    }
    t1.steps
}

fn solveb(filename: &str) -> usize {
    let (sx, sy, pipes) = parse(filename);

    let (mut t1, mut t2) = start_turts(sx, sy, &pipes);
    while t1.x != t2.x || t1.y != t2.y {
        assert!(t1.do_move(&pipes));
        assert!(t2.do_move(&pipes));
    }
    let seen: HashSet<(usize, usize)> =
        t1.seen.union(&t2.seen).map(|(x, y)| (*x, *y)).collect();

    let mut outs = vec![];
    if sy > 0 { match pipes[sy-1][sx] {
        '7' | '|' | 'F' => outs.push(Dir::Up),
        _ => ()
    }}
    if sx < pipes[0].len() - 1 { match pipes[sy][sx+1] {
        '7' | '-' | 'J' => outs.push(Dir::Right),
        _ => ()
    }}
    if sy < pipes.len() - 1 { match pipes[sy+1][sx] {
        'L' | '|' | 'J' => outs.push(Dir::Down),
        _ => ()
    }}
    if sx > 0 { match pipes[sy][sx-1] {
        'L' | '-' | 'F' => outs.push(Dir::Left),
        _ => ()
    }}
    let mut outsi = outs.iter();
    let start_pipe = match (outsi.next(), outsi.next()) {
        (Some(Dir::Up), Some(Dir::Right)  ) => 'L',
        (Some(Dir::Up), Some(Dir::Down)   ) => '|',
        (Some(Dir::Up), Some(Dir::Left)   ) => 'J',
        (Some(Dir::Right), Some(Dir::Down)) => 'F',
        (Some(Dir::Right), Some(Dir::Left)) => '-',
        (Some(Dir::Down), Some(Dir::Left) ) => '7',
        wat => panic!("Unmatched starting directions!? {:?}", wat),
    };
    //println!("Start pipe {}", start_pipe);
    pipes.iter().enumerate().map(|(y, l)|
        l.iter().enumerate().fold((0, None, 0), |(ins, pipe, now_in), (x, c)| {
            let real_c = match c {
                'S' => start_pipe,
                _ => *c
            };
            if seen.contains(&(x, y)) {
                // On the path
                match (pipe, real_c) {
                    (Some(_), '-') =>
                        // same old
                        (ins, pipe, now_in)
                    ,
                    (Some('F'), '7') | (Some('L'), 'J') =>
                        // not crossing
                        (ins, None, now_in)
                    ,
                    (Some('L'), '7') | (Some('F'), 'J') =>
                        // crossing
                        (ins, None, now_in ^ 1)
                    ,
                    (None, 'F') => (ins, Some('F'), now_in),
                    (None, 'L') => (ins, Some('L'), now_in),
                    (None, '|') => (ins, None, now_in ^ 1),
                    wat =>
                        panic!("Unknown match state {:?} at x={}, y={}", wat, x, y),
                }
            } else {
                // Not on the path, carry on
                (ins + now_in, pipe, now_in)
            }
        }).0
    ).sum()
}

fn parse(filename: &str) -> (usize, usize, Pipes) {
    let contents = fs::read_to_string(filename).expect("can't read file");
    let map: Pipes = contents.lines().map(|l| l.chars().collect() ).collect();
    for y in 0..map.len() {
        for x in 0..map[0].len() {
            if map[y][x] == 'S' {
                return (x, y, map);
            }
        }
    }
    panic!("No start found!");
}

fn dump(turtles: &Vec<&Turtle>, pipes: &Pipes) -> () {
    println!("======\n\n{}",
        pipes.iter().enumerate().map(|(y, l)|
            l.iter().enumerate().map(|(x, c)|
                turtles.iter().enumerate().filter_map(|(i, t)|
                   if t.x == x && t.y == y {
                       char::from_digit(i as u32, 36)
                   } else {
                       None
                   }
               ).nth(0).unwrap_or(*c)
            ).collect::<String>()
        ).collect::<Vec<String>>().join("\n")
    );
}
