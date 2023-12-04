use std::collections::HashSet;
use std::fs;

#[derive(Debug)]
struct Game {
    winners: HashSet<u64>,
    haves: HashSet<u64>,
}

fn main() {
    println!("Test a (13): {}", solvea("testa.txt"));
    println!("Solve a (24733): {}", solvea("input.txt"));
    println!("Test b (30): {}", solveb("testa.txt"));
    println!("Solve b (5422730): {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> u64 {
    let games = parse(filename);
    //println!("{:?}", games);
    games.iter().map(score).sum()
}

fn score(game: &Game) -> u64 {
    match game.winners.intersection(&game.haves).count() {
        0 => 0,
        n => 1 << (n - 1),
    }
}

fn solveb(filename: &str) -> u64 {
    let games = parse(filename);
    let mut copies: Vec<u64> = games.iter().map(|_| 1).collect();
    for (i, game) in games.iter().enumerate() {
        let num_matches = game.winners.intersection(&game.haves).count();
        for j in (i+1)..(i+1+num_matches) {
            copies[j] += copies[i];
        }
    }
    copies.iter().sum()
}

fn parse(filename: &str) -> Vec<Game> {
    let contents = fs::read_to_string(filename).expect("can't read file");

    contents.lines().map(|l| {
        let mut wins_and_nums = l.split(": ").nth(1).unwrap().split(" | ");
        let winners = str2nums(wins_and_nums.nth(0).unwrap());
        let haves = str2nums(wins_and_nums.nth(0).unwrap());
        Game { winners, haves }
    }).collect()
}

fn str2nums(s: &str) -> HashSet<u64> {
    s.split_whitespace().map(|n| n.parse::<u64>().unwrap()).collect()
}
