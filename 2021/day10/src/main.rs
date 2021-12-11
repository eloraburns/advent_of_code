fn main() {
    println!("10a(test): {}", solvea("test.txt"));
    println!("10b(test): {}", solveb("test.txt"));

    println!("10a(input): {}", solvea("input.txt"));
    println!("10b(input): {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> usize {
    std::fs::read_to_string(filename)
        .unwrap()
        .lines()
        .map(|l| -> usize {
            let mut stack = vec![];
            for c in l.chars() {
                match c {
                    '(' => stack.push(c),
                    '[' => stack.push(c),
                    '{' => stack.push(c),
                    '<' => stack.push(c),
                    ')' => if stack.pop() != Some('(') { return 3; },
                    ']' => if stack.pop() != Some('[') { return 57; },
                    '}' => if stack.pop() != Some('{') { return 1197; },
                    '>' => if stack.pop() != Some('<') { return 25137; },
                    _ => (),
                }
            }
            return 0;
        })
        .sum()
}

fn solveb(filename: &str) -> usize {
    let mut scores = std::fs::read_to_string(filename)
        .unwrap()
        .lines()
        .filter_map(calcb)
        .collect::<Vec<usize>>();
    scores.sort();
    // for s in &scores {
    //     println!("score: {}", s);
    // }
    scores[scores.len() / 2]
}

fn calcb(l: &str) -> Option<usize> {
    let mut stack = vec![];
    for c in l.chars() {
        match c {
            '(' => stack.push(')'),
            '[' => stack.push(']'),
            '{' => stack.push('}'),
            '<' => stack.push('>'),
            c => if stack.pop() != Some(c) { return None; },
        }
    }
    // let completion: String = stack
    //     .iter()
    //     .rev()
    //     .collect();
    // println!("{} ==: {}", l, completion);

    let mut score = 0;
    while let Some(c) = stack.pop() {
        score *= 5;
        match c {
            ')' => score += 1,
            ']' => score += 2,
            '}' => score += 3,
            '>' => score += 4,
            _ => panic!("unexpected stack contents {}", c),
        }
    }
    return Some(score);
}