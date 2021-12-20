use std::collections::HashSet;
use std::cmp::Reverse;

const ZERO: u8 = 48;

fn main() {
    println!("15a(test), expect 40: {}", solve(parsea("test.txt")));
    println!("15b(test), expect 315: {}", solve(parseb("test.txt")));

    // 697 is too high
    // 696 is right!
    println!("15a(input): {}", solve(parsea("input.txt")));
    println!("15b(input): {}", solve(parseb("input.txt")));
}

fn parsea(filename: &str) -> Vec<Vec<usize>> {
    std::fs::read_to_string(filename)
        .unwrap()
        .lines()
        .map(|l| {
            l.bytes().map(|b| (b - ZERO) as usize).collect()
        })
        .collect()
}

fn parseb(filename: &str) -> Vec<Vec<usize>> {
    let smallcave = parsea(filename);
    let smallwidth = smallcave.first().unwrap().len();
    let smallheight = smallcave.len();
    (0..(smallheight * 5))
        .map(|i| i / smallheight)
        .zip(smallcave.iter().cycle())
        .map(|(i, row)| {
            (0..(smallwidth * 5))
                .map(|j| j / smallwidth)
                .zip(row.iter().cycle())
                .map(|(j, c)| {
                    let new_c = i + j + c;
                    if new_c > 9 {
                        new_c - 9
                    } else {
                        new_c
                    }
                })
                .collect()
        })
        .collect()
}

struct SeenNode {
    cost: usize,
    x: usize,
    y: usize,
}

fn solve(cave: Vec<Vec<usize>>) -> usize {
    let width = cave.first().unwrap().len();
    let height = cave.len();
    let end_x = width - 1;
    let end_y = height - 1;

    let mut horizon: Vec<SeenNode> = vec![SeenNode { cost: 0, x: 0, y: 0 }];
    let mut donezo: HashSet<(usize, usize)> = HashSet::new();
    let mut pathcosts: Vec<Vec<usize>> = vec![vec![usize::MAX; width]; height];
    pathcosts[0][0] = 0;
    // print_pathcosts(&cave);
    loop {
        // print_pathcosts(&pathcosts);
        horizon.sort_by_key(|a| Reverse(a.cost));
        let here = horizon.pop().unwrap();
        let x = here.x;
        let y = here.y;
        if x == end_x && y == end_y {
            return here.cost;
        }
        if x > 0 && !donezo.contains(&(x-1, y)) && (here.cost + cave[y][x-1]) < pathcosts[y][x-1] {
            let new_pathcost = here.cost + cave[y][x-1];
            pathcosts[y][x-1] = new_pathcost;
            let mut i = usize::MAX;
            for (si, s) in horizon.iter().enumerate() {
                if s.x == x-1 && s.y == y {
                    i = si;
                    break;
                } 
            }
            if i < usize::MAX {
                horizon[i].cost = new_pathcost;
            } else {
                horizon.push(SeenNode { cost: new_pathcost, x: x-1, y: y });
            }
        }
        if x < end_x && !donezo.contains(&(x+1, y)) && (here.cost + cave[y][x+1]) < pathcosts[y][x+1] {
            let new_pathcost = here.cost + cave[y][x+1];
            pathcosts[y][x+1] = new_pathcost;
            let mut i = usize::MAX;
            for (si, s) in horizon.iter().enumerate() {
                if s.x == x+1 && s.y == y {
                    i = si;
                    break;
                } 
            }
            if i < usize::MAX {
                horizon[i].cost = new_pathcost;
            } else {
                horizon.push(SeenNode { cost: new_pathcost, x: x+1, y: y });
            }
        }
        if y > 0 && !donezo.contains(&(x, y-1)) && (here.cost + cave[y-1][x]) < pathcosts[y-1][x] {
            let new_pathcost = here.cost + cave[y-1][x];
            pathcosts[y-1][x] = new_pathcost;
            let mut i = usize::MAX;
            for (si, s) in horizon.iter().enumerate() {
                if s.x == x && s.y == y-1 {
                    i = si;
                    break;
                } 
            }
            if i < usize::MAX {
                horizon[i].cost = new_pathcost;
            } else {
                horizon.push(SeenNode { cost: new_pathcost, x: x, y: y-1 });
            }
        }
        if y < end_y && !donezo.contains(&(x, y+1)) && (here.cost + cave[y+1][x]) < pathcosts[y+1][x] {
            let new_pathcost = here.cost + cave[y+1][x];
            pathcosts[y+1][x] = new_pathcost;
            let mut i = usize::MAX;
            for (si, s) in horizon.iter().enumerate() {
                if s.x == x && s.y == y+1 {
                    i = si;
                    break;
                } 
            }
            if i < usize::MAX {
                horizon[i].cost = new_pathcost;
            } else {
                horizon.push(SeenNode { cost: new_pathcost, x: x, y: y+1 });
            }
        }
        donezo.insert((x, y));
    }
}

fn print_pathcosts(p: &Vec<Vec<usize>>) {
    for y in 0..p.len() {
        for x in 0..p.first().unwrap().len() {
            if p[y][x] == usize::MAX {
                print!("  *");
            } else {
                print!("{:3}", p[y][x]);
            }
        }
        println!();
    }
}