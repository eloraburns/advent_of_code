use std::fs;

struct Grab {
    red: u64,
    green: u64,
    blue: u64,
}

fn main() {
    println!("Test a (8): {}", solvea("testa.txt"));
    println!("Solve a: {}", solvea("input.txt"));

    println!("Test b (2286): {}", solveb("testa.txt"));
    println!("Solve b: {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> u64 {
    let parsed = parse(filename);
    let maxes = Grab { red: 12, green: 13, blue: 14 };
    let it = parsed.iter();
    it.filter_map(|(i, grabs)| {
        if grabs.iter().all(|g| g.red <= maxes.red && g.green <= maxes.green && g.blue <= maxes.blue) {
            Some(i)
        } else {
            None
        }
    }).sum()
}

fn solveb(filename: &str) -> u64 {
    let parsed = parse(filename);
    parsed.iter().map(|(_, grabs)| {
        let mut min_in_bag = Grab { red: 0, green: 0, blue: 0 };
        for g in grabs {
            if min_in_bag.red < g.red { min_in_bag.red = g.red }
            if min_in_bag.green < g.green { min_in_bag.green = g.green }
            if min_in_bag.blue < g.blue { min_in_bag.blue = g.blue }
        }
        min_in_bag.red * min_in_bag.green * min_in_bag.blue
    }).sum() 
}

fn parse(filename: &str) -> Vec<(u64, Vec<Grab>)> {
    let contents = fs::read_to_string(filename).expect("can't read file");

    contents.lines().map(|l| {
        let mut grabs = Vec::new();
        let mut game = l.split(": ");
        let mut game_with_num = game.next().unwrap().split(" ");
        game_with_num.next();
        let gamenum = game_with_num.next().unwrap().parse::<u64>().unwrap();
        for g in game.next().unwrap().split("; ") {
            let mut grab = Grab {red: 0, green: 0, blue: 0};
            for gg in g.split(", ") {
                let mut ggeach = gg.split(" ");
                let num = ggeach.next().unwrap().parse::<u64>().unwrap();
                let colour = ggeach.next().unwrap();
                match colour {
                    "red" => grab.red = num,
                    "green" => grab.green = num,
                    "blue" => grab.blue = num,
                    _ => panic!("{} is not a recognized colour", colour)
                }
            }
            grabs.push(grab)
        }
        (gamenum, grabs)
    }).collect()
}
