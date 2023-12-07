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

#[derive(Clone)]
#[derive(Debug)]
#[derive(Eq)]
#[derive(PartialEq)]
struct Mapping {
    upto: i64,
    delta: i64,
}

#[derive(Debug)]
#[derive(Eq)]
#[derive(PartialEq)]
struct Mappings {
    m: Vec<Mapping>
}

impl Mappings {
    fn map(&self, n: i64) -> i64 {
        for m in self.m.iter() {
            if n < m.upto {
                return n + m.delta;
            }
        }
        return n;
    }

    // a, b, 5
    // c, d, 5
    //
    // upto: a, delta: 0
    // upto: f, delta: 1
    // upto: M, delta: 0
    // +
    // upto: c, delta: 0
    // upto: h, delta: 1
    // upto: M, delta: 0
    // =
    // upto: a, delta: 0
    // upto: b, delta: 1
    // upto: f, delta: 2
    // upto: g, delta: 1
    // upto: h, delta: 1
    // upto: M, delta: 0
    // a <              
    // b |   > a       a
    // c |---| b <      
    // d |   | c |   > b
    // e <   | d |---| c
    // f     > e |   | d
    // g       g <   | ef
    // h       h     > g
    // i       i       i

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
    fn new() -> Mappings {
        Mappings {
            m: vec![Mapping { upto: i64::MAX, delta: 0 }]
        }
    }

    fn xlate(m: &ParsedMapping) -> Mapping {
        Mapping {
            upto: m.source + m.length,
            delta: m.dest - m.source
        }
    }

    fn apply_parsed_mappings(maps: &Vec<ParsedMapping>, mapping: &Mappings) -> Mappings {
        let mut smaps = maps.clone();
        smaps.sort();
        let mut mapi = 0;
        let mut rangei = 0;
        let mut out = vec![];
        loop {
            if (mapi >= maps.len() || rangei >= mapping.m.len()) {
                break;
            }
            match (&maps[mapi], &mapping.m[rangei]) {
                (ParsedMapping{source, dest, length}, Mapping{upto, delta})
                if (source+length < *upto) => {
                    out.push(Mapping { upto: *source, delta: *delta });
                    out.push(Mapping { upto: *source+*length, delta: *delta + *dest - *source});
                    mapi += 1;
                },
                _ => break
            }
        };
        while rangei < mapping.m.len() {
            out.push(mapping.m[rangei].clone());
            rangei += 1;
        }

        Mappings { m: out }
    }
}

#[test]
fn try_mapping() {
    let ms = Mappings {
        m: vec![
            Mapping { upto: 0, delta: 0 },
            Mapping { upto: 5, delta: 5 },
            Mapping { upto: 10, delta: -5},
            Mapping { upto: i64::MAX, delta: 0},
        ]
    };
    assert_eq!(1, ms.map(6));
    assert_eq!(7, ms.map(2));
    assert_eq!(11, ms.map(11));
}

#[test]
fn test_apply_parsed_mappings_simple() {
    let actual = Mappings::apply_parsed_mappings(
        &vec![ParsedMapping{ source: 0, dest: 1, length: 1 }],
        &Mappings::new()
    );
    assert_eq!(Mappings { m: vec![
        Mapping { upto: 0, delta: 0 },
        Mapping { upto: 1, delta: 1 },
        Mapping { upto: i64::MAX, delta: 0}
    ]}, actual);
}

#[test]
fn test_apply_parsed_mappings_parsed_crosses_range() {
    let actual = Mappings::apply_parsed_mappings(
        &vec![ParsedMapping{ source: 0, dest: 40, length: 20 }],
        &Mappings { m: vec![
            Mapping { upto: 10, delta: 1 },
            Mapping { upto: i64::MAX, delta: 0}
        ]}
    );
    assert_eq!(Mappings { m: vec![
        Mapping { upto: 0, delta: 1 },
        Mapping { upto: 10, delta: 41 },
        Mapping { upto: 20, delta: 40 },
        Mapping { upto: i64::MAX, delta: 0}
    ]}, actual);
}

fn main() {
    println!("Test a (35): {}", solvea("testa.txt"));
    println!("Solve a (836040384): {}", solvea("input.txt"));
    println!("Test b (46): {}", solveb("testa.txt"));
    println!("Solve b (?): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> (Vec<i64>, Vec<Mappings>) {
    let binding = std::fs::read_to_string(filename).unwrap();
    let mut sections = binding.split("\n\n");
    let seeds: Vec<i64> = sections.next().unwrap()
        .split(": ").nth(1).unwrap()
        .split(" ").map(|n| n.parse::<i64>().unwrap())
        .collect();
    let mappingses = sections.map(|s| {
        let mut lines = s.lines();
        lines.next(); // get rid of the header, it's irrelevant
        Mappings::apply_parsed_mappings(
            &lines.map(|l| {
                   let nums: Vec<i64> = l.split(" ")
                       .map(|n| n.parse().unwrap()).collect();
                   ParsedMapping { source: nums[1], dest: nums[0], length: nums[2] }
            }).collect(),
            &Mappings::new()
        )
    }).collect();

    (seeds, mappingses)
}

fn solvea(filename: &str) -> i64 {
    let (seeds, mappingses) = parse(filename);
    seeds.iter().map(|&seed|
        mappingses.iter().fold(seed, |acc, m| m.map(acc))
    ).min().unwrap()
}

fn solveb(filename: &str) -> i64 {
    // Ok, so we have to figure out how to flatten the maps (merge range rewrites)
    // and then only look at the places where seed ranges start, and where they
    // intersect with discontinuities in the total mapping.
    0
}
