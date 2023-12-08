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
    from: i64,
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

    fn parsed_to_mappings(maps: &Vec<ParsedMapping>) -> Mappings {
        let mut smaps = maps.clone();
        smaps.sort();
        let mut dmaps = vec![];

        dmaps.push(Mapping { from: i64::MIN, upto: smaps[0].source, delta: 0 });

        let last_smaps = smaps.len() - 1;
        for i in 0..smaps.len() {
            dmaps.push(Mapping {
                from: smaps[i].source,
                upto: smaps[i].source + smaps[i].length,
                delta: smaps[i].dest - smaps[i].source
            });
            if i == last_smaps {
                dmaps.push(Mapping {
                    from: smaps[i].source + smaps[i].length,
                    upto: i64::MAX,
                    delta: 0
                });
            } else if smaps[i].source + smaps[i].length < smaps[i+1].source {
                dmaps.push(Mapping {
                    from: smaps[i].source + smaps[i].length,
                    upto: smaps[i+1].source,
                    delta: 0
                });
            }
        }
        Mappings { m: dmaps }
    }

    fn merge_mappings(m1: &Mappings, m2: &Mappings) -> Mappings {
        let mut newmaps = vec![];



        Mappings { m: newmaps }
    }
}

#[test]
fn try_mapping() {
    let ms = Mappings {
        m: vec![
            Mapping { from: i64::MIN, upto:        0, delta:  0 },
            Mapping { from:        0, upto:        5, delta:  5 },
            Mapping { from:        5, upto:       10, delta: -5 },
            Mapping { from:       10, upto: i64::MAX, delta:  0 },
        ]
    };
    assert_eq!(-1, ms.map(-1));
    assert_eq!(1, ms.map(6));
    assert_eq!(7, ms.map(2));
    assert_eq!(11, ms.map(11));
}

#[test]
fn test_parsed_to_mappings() {
    let actual = Mappings::parsed_to_mappings(&vec![
        ParsedMapping{ source: 0, dest: 10, length: 5 },
        ParsedMapping{ source: 10, dest: 0, length: 5 },
        ParsedMapping{ source: 16, dest: 17, length: 2}
    ]);
    assert_eq!(Mappings { m: vec![
        Mapping { from: i64::MIN, upto:        0, delta:   0 },
        Mapping { from:        0, upto:        5, delta:  10 },
        Mapping { from:        5, upto:       10, delta:   0 },
        Mapping { from:       10, upto:       15, delta: -10 },
        Mapping { from:       15, upto:       16, delta:   0 },
        Mapping { from:       16, upto:       18, delta:   1 },
        Mapping { from:       18, upto: i64::MAX, delta:   0 },
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
        Mappings::parsed_to_mappings(
            &lines.map(|l| {
                   let nums: Vec<i64> = l.split(" ")
                       .map(|n| n.parse().unwrap()).collect();
                   ParsedMapping { source: nums[1], dest: nums[0], length: nums[2] }
            }).collect()
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
