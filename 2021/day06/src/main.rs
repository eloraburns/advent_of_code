use std::fs;

fn main() {
    assert!(solve("test.txt", "a", 80) == 5934);
    assert!(solve("test.txt", "b", 256) == 26984457539);

    solve("input.txt", "a", 80);
    solve("input.txt", "b", 256);

}

fn solve(filename: &str, part: &str, iterations: usize) -> u64 {
    let mut pops: Vec<u64> = vec![0; 9];
    fs::read_to_string(filename)
        .expect("can't read")
        .trim()
        .split(",")
        .for_each(|age_str|
            pops[age_str.parse::<usize>().unwrap()] += 1
        );

    for day in 0..iterations {
        // a b c d e f g h i
        // 0 1 2 3 4 5 6 7 8 0
        // | a b c d e f g h i
        // | 0 1 2 3 4 5 6 7 8
        // +-------------^
        pops[(day+7) % 9] += pops[day % 9];
    }
    
    let answer = pops.iter().fold(0, |a, b| a + b);
    println!("6{}({}): {}", part, filename, answer);
    return answer;
}
