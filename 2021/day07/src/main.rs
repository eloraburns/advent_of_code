use std::fs;

struct Input {
    crabs: Vec<usize>,
    min_crab: usize,
    max_crab: usize,
}

fn main() {
    let test_data = parse("test.txt");
    println!("7a(test): {}", solvea(&test_data));
    println!("7b(test): {}", solveb(&test_data));

    let input_data = parse("input.txt");
    println!("7a(input): {}", solvea(&input_data));
    println!("7b(input): {}", solveb(&input_data));
}

fn parse(filename: &str) -> Input {
    let crabs: Vec<usize> = fs::read_to_string(filename)
        .expect("can't read file")
        .trim()
        .split(",")
        .map(|c| c.parse::<usize>().unwrap())
        .collect();

    let min_crab = *crabs.iter().min().unwrap();
    let max_crab = *crabs.iter().max().unwrap();

    Input {crabs, min_crab, max_crab}
}

fn solvea(input: &Input) -> usize {
    let mut fuel_consumptions: Vec<usize> = (input.min_crab..input.max_crab)
        .map(|target|
            input.crabs
                .iter()
                .map(|c| (target as i32 - (*c as i32)).abs() as usize)
                .fold(0, |a, b| a + b)
        )
        .collect();
    fuel_consumptions.sort();
    // 355150
    return *fuel_consumptions.iter().min().unwrap();
}

fn solveb(input: &Input) -> usize {
    let mut costs = vec![0; (input.max_crab as usize)+1];
    for i in 1..((input.max_crab as usize) + 1) {
        costs[i] = costs[i-1] + i;
    }

    let mut fuel_consumptions: Vec<usize> = (input.min_crab..input.max_crab)
        .map(|target|
            input.crabs
                .iter()
                .map(|c| {
                    costs[(target as i32 - (*c as i32)).abs() as usize]
                })
                .fold(0, |a, b| a + b)
        )
        .collect();
    fuel_consumptions.sort();
    // 98368490
    return *fuel_consumptions.iter().min().unwrap();
}