use std::collections::{HashMap, HashSet};

fn main() {
    println!("12a(test1): {} (expect 10)", solvea("test1.txt"));
    println!("12a(test2): {} (expect 19)", solvea("test2.txt"));
    println!("12a(test3): {} (expect 226)", solvea("test3.txt"));
    println!("12b(test1): {} (expect 36)", solveb("test1.txt"));
    println!("12b(test2): {} (expect 103)", solveb("test2.txt"));
    println!("12b(test3): {} (expect 3509)", solveb("test3.txt"));

    println!("12a(input): {}", solvea("input.txt"));
    println!("12b(input): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> HashMap<String, Vec<String>> {
    let mut paths: HashMap<String, Vec<String>> = HashMap::new();
    let stuff = std::fs::read_to_string(filename)
        .expect("missing input file");
    stuff
        .lines()
        .for_each(|l| {
            let parts: Vec<_> = l.split("-").collect();
            match paths.get_mut(parts[0]) {
                Some(destinations) => destinations.push(parts[1].to_string()),
                None => {
                    paths.insert(parts[0].to_string(), vec![parts[1].to_string()]);
                    ()
                },
            }
            match paths.get_mut(parts[1]) {
                Some(destinations) => destinations.push(parts[0].to_string()),
                None => {
                    paths.insert(parts[1].to_string(), vec![parts[0].to_string()]);
                    ()
                },
            }
        });
        paths
}

fn solvea(filename: &str) -> usize {
    let paths = parse(filename);
    let seen: HashSet<String> = HashSet::new();
    let num_paths = walka("start", &paths, seen);
    return num_paths;
}

fn walka(at: &str, map: &HashMap<String, Vec<String>>, seen: HashSet<String>) -> usize {
    let mut num_paths = 0;
    let mut my_seen = seen.clone();
    my_seen.insert(at.to_string());
    for dest in map.get(at).unwrap() {
        if is_once_only(dest) && my_seen.contains(dest) {
            continue;
        }
        if *dest == "end" {
            num_paths += 1;
        }
        num_paths += walka(dest, map, my_seen.clone());
    }
    return num_paths;
}

fn is_once_only(dest: &str) -> bool {
    let first = dest.chars().next().unwrap();
    'a' <= first && first <= 'z'
}

fn solveb(filename: &str) -> usize {
    let paths = parse(filename);
    let seen: HashSet<String> = HashSet::new();
    let num_paths = walkb("start", &paths, seen, false);
    return num_paths;
}

fn walkb(at: &str, map: &HashMap<String, Vec<String>>, seen: HashSet<String>, have_doubled_back: bool) -> usize {
    let mut num_paths = 0;
    let mut my_seen = seen.clone();
    my_seen.insert(at.to_string());
    for dest in map.get(at).unwrap() {
        if *dest == "end" {
            num_paths += 1;
        } else if *dest == "start" {
            continue;
        } else if is_once_only(dest) && my_seen.contains(dest) {
            if have_doubled_back {
                continue;
            } else {
                num_paths += walkb(dest, map, my_seen.clone(), true);
            }
        } else {
            num_paths += walkb(dest, map, my_seen.clone(), have_doubled_back);
        }
    }
    return num_paths;
}