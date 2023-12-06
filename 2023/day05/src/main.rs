use std::fs;

#[derive(Clone)]
#[derive(Debug)]
#[derive(Eq)]
#[derive(Ord)]
#[derive(PartialEq)]
#[derive(PartialOrd)]
struct ParsedMapping {
    source: i64,
    dest: i64,
    length: i64,
}

struct Mapping {
    upto: i64,
    delta: i64,
}

#[derive(Debug)]
struct Mappings {
    m: Vec<Mapping>
}

impl Mappings {
    fn map(&self, n: u64) -> u64 {
        for m in self.m.iter() {
            if n < m.upto {
                return n + m.delta;
            }
        }
        return n;
    }

    fn make_mappings(maps: Vec<ParsedMapping>) -> Mappings {
        let mut smaps = maps.clone();
        smaps.sort();
        let mut omaps = smaps.flat_map(|m| {
        })
        Mappings { m: smaps }
    }

    // a, b, 5
    // c, d, 5
    // a <              
    // b |   > a       a
    // c |---| b <      
    // d |   | c |   > b
    // e <   | d |---| c
    // f     > e |   | d
    // g       g <   | e
    // h       h     > g

    // a, b, 1
    // b, d, 4
    // g, h, 1
    // a]-----------+   
    // b<           +-[a
    // c|               
    // d|-------+     >b
    // e<       +-----|c
    // f              |d
    // g]-----+       >e
    // h      +-------[g

    // Six cases (excluding exact boundary matches):
    //
    //   ^     ^     ^                  
    //   V     |     |                  
    // ^     ^ |   ^ |   ^     ^     ^  
    // |     | v   | |   | ^   | ^   |  
    // |     |     | |   | v   | |   |  
    // v     v     v |   v     v |   v  
    //               v           v    ^ 
    //                                v 

    // WAIT A SEC. Instead of fromrange->torange, it'll be easier
    // to stack if we represent it as "up to this number, delta is X".
    // upto: a, delta: 0
    // upto: f: delta: 1
    // upto: MAXINT, delta: 0
    fn merge_mappingses(maps1: Mappings, maps2: Mappings) -> Mappings {
        maps1
    }
}

#[test]
fn try_mapping() {
    let ms = Mappings {
        m: vec![
            Mapping { source: 5, dest: 0, length: 5 },
            Mapping { source: 0, dest: 5, length: 5 },
        ]
    };
    assert_eq!(1, ms.map(6));
    assert_eq!(7, ms.map(2));
    assert_eq!(11, ms.map(11));
}

#[test]
fn 

fn main() {
    println!("Test a (35): {}", solvea("testa.txt"));
    println!("Solve a (836040384): {}", solvea("input.txt"));
    println!("Test b (46): {}", solveb("testa.txt"));
    println!("Solve b (?): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> (Vec<u64>, Vec<Mappings>) {
    let binding = std::fs::read_to_string(filename).unwrap();
    let mut sections = binding.split("\n\n");
    let seeds: Vec<u64> = sections.next().unwrap()
        .split(": ").nth(1).unwrap()
        .split(" ").map(|n| n.parse::<u64>().unwrap())
        .collect();
    let mappingses = sections.map(|s| {
        let mut lines = s.lines();
        lines.next(); // get rid of the header, it's irrelevant
        Mappings::make_mappingses(
            lines.map(|l| {
                   let nums: Vec<u64> = l.split(" ")
                       .map(|n| n.parse().unwrap()).collect();
                   Mapping { source: nums[1], dest: nums[0], length: nums[2] }
            }).collect()
        )
    }).collect();

    (seeds, mappingses)
}

fn solvea(filename: &str) -> u64 {
    let (seeds, mappingses) = parse(filename);
    seeds.iter().map(|&seed|
        mappingses.iter().fold(seed, |acc, m| m.map(acc))
    ).min().unwrap()
}

fn solveb(filename: &str) -> u64 {
    // Ok, so we have to figure out how to flatten the maps (merge range rewrites)
    // and then only look at the places where seed ranges start, and where they
    // intersect with discontinuities in the total mapping.
    0
}
