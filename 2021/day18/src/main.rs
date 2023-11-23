use day18::*;

fn main() {
    println!("18a(test, expect 4140): {}", solvea("test.txt"));
    
}

fn solvea(filename: &str) -> usize {
    let contents = std::fs::read_to_string(filename).unwrap();
    let s = parse(&contents);
    println!("QUACK: {}", s);
    0
}