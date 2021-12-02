use std::fs;

fn main() {
	let contents = fs::read_to_string("input.txt")
		.expect("can't read file");

	let depths: Vec<u32> = contents.lines()
		.map(|l| -> u32 { l.parse().unwrap() })
		.collect();

	println!("1a: {}", solve1a(&depths));
	println!("1b: {}", solve1b(&depths));
}

fn solve1a(depths: &Vec<u32>) -> u32 {
	let mut increases = 0;
	for i in 1..(depths.len()) {
		if depths[i-1] < depths[i] {
			increases = increases + 1;
		}
	}
	return increases;
}

fn solve1b(depths: &Vec<u32>) -> u32 {
	let mut increases = 0;
	for i in 3..(depths.len()) {
		if depths[i-3] < depths[i] {
			increases = increases + 1;
		}
	}
	return increases;
}