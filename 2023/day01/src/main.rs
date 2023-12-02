use regex::Regex;
use std::fs;

fn main() {
    println!("Test 1a (142): {}", solve1a("test.txt"));
    // 2161200 is too high
    // 53080
    println!("Solve 1a: {}", solve1a("input.txt"));

    println!("Test 1b (281): {}", solve1b("testb.txt"));
    println!("Solve 1b: {}", solve1b("input.txt"));
}

fn solve1a(filename: &str) -> u64 {
	let contents = fs::read_to_string(filename)
		.expect("can't read file");

    let rl = Regex::new(r"(\d)").unwrap();
    let rr = Regex::new(r".*(\d)").unwrap();
    contents.lines().map(|l| {
      let tens = rl.captures(l).unwrap()[1].parse::<u64>().unwrap();
      let ones = rr.captures(l).unwrap()[1].parse::<u64>().unwrap();
      let calval = tens * 10 + ones;
      // println!("acc: {}", calval);
      calval
    }).sum()
}

fn solve1b(filename: &str) -> u64 {
	let contents = fs::read_to_string(filename)
		.expect("can't read file");

    let rl = Regex::new(r"(\d|one|two|three|four|five|six|seven|eight|nine)").unwrap();
    let rr = Regex::new(r".*(\d|one|two|three|four|five|six|seven|eight|nine)").unwrap();
    contents.lines().map(|l| {
      let tens = to_int(&rl.captures(l).unwrap()[1]);
      let ones = to_int(&rr.captures(l).unwrap()[1]);
      let calval = tens * 10 + ones;
      // println!("acc: {}", calval);
      calval
    }).sum()
}

fn to_int(s: &str) -> u64 {
  match s {
    "one" | "1" => 1,
    "two" | "2" => 2,
    "three" | "3" => 3,
    "four" | "4" => 4,
    "five" | "5" => 5,
    "six" | "6" => 6,
    "seven" | "7" => 7,
    "eight" | "8" => 8,
    "nine" | "9" => 9,
    _ => panic!("no clue what {} is", s)
  }
}
