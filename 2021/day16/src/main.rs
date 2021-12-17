use day16::{str_to_bitstream, parse};

fn main() {
    println!("16a: {}", solvea("input.txt"));
    println!("16b: {}", solveb("input.txt"));
}

fn solvea(filename: &str) -> usize {
    let contents = std::fs::read_to_string(filename).unwrap();
    let b = str_to_bitstream(&contents);
    return parse(&b).version_sum;
}

fn solveb(filename: &str) -> usize {
    let contents = std::fs::read_to_string(filename).unwrap();
    let b = str_to_bitstream(&contents);
    return parse(&b).value;
}