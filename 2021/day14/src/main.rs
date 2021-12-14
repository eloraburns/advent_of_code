use std::collections::HashMap;

fn main() {
    println!("14a(test): {} (expect 1588)", solvea("test.txt"));
    println!("14b(test): {}", solveb("test.txt"));
    println!("   (expect 2188189693529)");
    println!();
    println!("14a(input): {}", solvea("input.txt"));
    println!("14b(input): {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> usize {
    let input = std::fs::read_to_string(filename).unwrap();
    let mut parts = input.split("\n\n");
    let mut chain: Vec<_> = parts.next().unwrap().chars().collect();
    let rules: HashMap<_, _> = parts.next().unwrap().lines()
        .map(|l| {
            ((l.chars().nth(0).unwrap(), l.chars().nth(1).unwrap()), l.chars().nth(6).unwrap())
        }).collect();
    for _ in 0..10 {
        let mut newchain = Vec::with_capacity(chain.len() * 2);
        for i in 0..(chain.len() - 1) {
            newchain.push(chain[i]);
            newchain.push(rules[&(chain[i], chain[i+1])]);
        }
        newchain.push(chain[chain.len() - 1]);
        chain = newchain;
    }
    let mut populations: HashMap<char, usize> = HashMap::new();
    for c in chain {
        match populations.get_mut(&c) {
            Some(v) => *v += 1,
            None => { populations.insert(c, 1); () },
        }
    }
    let mut popsort: Vec<usize> = populations
        .iter()
        .map(|(_, v)| *v)
        .collect();
    popsort.sort();
    return popsort.last().unwrap() - popsort[0];
}

fn solveb(filename: &str) -> usize {
    let input = std::fs::read_to_string(filename).unwrap();
    let mut parts = input.split("\n\n");
    let chain: Vec<_> = parts.next().unwrap().chars().collect();
    let first = chain[0];
    let last = chain[chain.len()-1];
    let mut components: HashMap<(char, char), usize> = HashMap::new();
    for i in 0..(chain.len()-1) {
        *components.entry((chain[i], chain[i+1])).or_insert(0) += 1;
    }
    let rules: HashMap<_, _> = parts.next().unwrap().lines()
        .map(|l| {
            ((l.chars().nth(0).unwrap(), l.chars().nth(1).unwrap()), l.chars().nth(6).unwrap())
        }).collect();

    for _ in 0..40 {
        let mut new_components = HashMap::new();
        for ((a, c), count) in components {
            let b = rules[&(a, c)];
            *new_components.entry((a,b)).or_insert(0) += count;
            *new_components.entry((b,c)).or_insert(0) += count;
        }
        components = new_components;
    }
    let mut populations: HashMap<char, usize> = vec![(first, 1), (last, 1)].into_iter().collect();
    for ((a, b), count) in components {
        *populations.entry(a).or_insert(0) += count;
        *populations.entry(b).or_insert(0) += count;
    }
    let mut popsort: Vec<usize> = populations.iter()
        .map(|(_, v)| *v).collect();
    popsort.sort();
    return (popsort[popsort.len()-1] - popsort[0]) / 2;
}