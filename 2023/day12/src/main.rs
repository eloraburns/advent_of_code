use std::fmt;
use std::fs;

struct Record {
    working_mask: u128,
    damaged_mask: u128,
    length: usize,
    pattern: Vec<u64>
}

impl Record {
    fn fivex(&self) -> Record {
        let base_working_mask = self.working_mask >> 1;
        let base_damaged_mask = self.damaged_mask >> 1;
        Record {
            // Extending by 1 bit so we don't have to check for negative offsets
            working_mask:
                ((base_working_mask
                | (base_working_mask << ((self.length) * 1))
                | (base_working_mask << ((self.length) * 2))
                | (base_working_mask << ((self.length) * 3))
                | (base_working_mask << ((self.length) * 4))) << 1) | 1,
            damaged_mask:
                (base_damaged_mask
                | (base_damaged_mask << ((self.length) * 1))
                | (base_damaged_mask << ((self.length) * 2))
                | (base_damaged_mask << ((self.length) * 3))
                | (base_damaged_mask << ((self.length) * 4))) << 1,
            length: (self.length - 1) * 5 + 4 + 1,
            pattern: self.pattern.clone()
                .into_iter().cycle()
                .take(self.pattern.len() * 5)
                .collect()
        }
    }
}

impl fmt::Debug for Record {
    fn fmt(&self, fmt: &mut fmt::Formatter<'_>) -> fmt::Result {
        let width = self.length;
        let map: String = (0..self.length).map(|i| 1 << i).map(|i|
            if self.working_mask & i > 0 {
                '.'
            } else if self.damaged_mask & i > 0 {
                '#'
            } else {
                '?'
            }
        ).collect();
        fmt.debug_struct("Record")
            .field("map", &map)
            //.field("working_mask", &format_args!("{0:0>width$b}", self.working_mask))
            //.field("damaged_mask", &format_args!("{0:0>width$b}", self.damaged_mask))
            .field("length", &self.length)
            .field("pattern", &self.pattern)
            .finish()
    }
}

#[test]
fn test_fivex() {
    let mut r = Record {
        working_mask: 0b01,
        damaged_mask: 0b10,
        length: 2,
        pattern: vec![1],
    };
    let mut r2 = r.fivex();
    assert_eq!(r2.working_mask, 0b0000000001, "'empty' working mask extends cleanly");
    assert_eq!(r2.damaged_mask, 0b1010101010, "damaged mask extends cleanly");
    assert_eq!(r2.length, 10, "5 plus 4 plus 1");
}

#[derive(Debug)]
struct Span {
    offset: usize,
    length: usize,
    mask: u128,
}

impl Span {
    fn new(length: usize) -> Span {
        Span { offset: 0, length, mask: (1 << length) - 1 }
    }

    fn is_clean(&self, r: &Record) -> bool {
        for i in self.offset..(self.offset + self.length) {
            let bit = 1 << i;
            // If its not marked as damaged, or is marked as working
            //println!("checking bit 0b{bit:0b}");
            //println!("bit & r.damaged_mask => {}", bit & r.damaged_mask);
            //println!("bit & r.damaged_mask == 0 => {}", (bit & r.damaged_mask)==0);
            //println!("bit & r.working_mask => {}", bit & r.working_mask);
            //println!("bit & r.working_mask == bit => {}", (bit & r.working_mask) == bit);
            if ((bit & r.damaged_mask) == 0) && ((bit & r.working_mask) == bit) {
                //println!("FALSE");
                // we don't fit here
                return false;
            }
        }
        let lastbit = 1 << (self.offset + self.length);
        //println!("checking last bit 0b{lastbit:0b}");
        // But if the spring _after_ us is not known to be damaged or is in fact
        // working, then we _are_ still in good stead.
        lastbit & r.damaged_mask == 0 || lastbit & r.working_mask == 1
    }
}

#[test]
fn test_span_is_clean() {
    let mut s = Span::new(1);
    let mut r = Record{ working_mask: 0, damaged_mask: 0, length: 5, pattern: vec![] };
    assert!(s.is_clean(&r), "# should fit into ?????");

    r.damaged_mask = 0b1;
    assert!(s.is_clean(&r), "# should fit into #????");

    r.damaged_mask = 0;
    r.working_mask = 0b1;
    assert!(!s.is_clean(&r), "# should not fit into .????");
}

fn main() {
    //println!("Test a (21): {}", solvea("testa.txt"));
    //println!("Solve a (7716): {}", solvea("input.txt"));
    //println!("Test b (525152): {}", solveb("testa.txt"));
    println!("Solve b (?): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> Vec<Record> {
    let contents = fs::read_to_string(filename).expect("can't read file");

    contents.lines().map(|l| {
        let mut rec1_rec2 = l.split(" ");
        let rec1 = rec1_rec2.next().unwrap();
        let rec2 = rec1_rec2.next().unwrap();

        let length = rec1.len();

        let (working_mask, damaged_mask) = rec1.chars().enumerate().fold(
            (0, 0), |(w, d), (i, c)| {
              let wset: u128 = if c == '.' { 1 << i } else { 0 };
              let dset: u128 = if c == '#' { 1 << i } else { 0 };
              (w | wset, d | dset)
            });

        let pattern = rec2.split(",").map(|n| n.parse::<u64>().unwrap()).collect();

        Record {
            // Extending by 1 bit so we don't have to check for negative offsets
            working_mask: (working_mask << 1) + 1,
            damaged_mask: damaged_mask << 1,
            length: length + 1,
            pattern
        }
    }).collect()
}

fn num_combos(r: &Record) -> u64 {
    let minlength = r.pattern.iter().map(|n|
        // Each chunk of damaged springs needs a good one in between
        n + 1
    ).sum::<u64>() - 1; // Except the last one, so subtract one
    let free = r.length as u64 - minlength;
    let mut patbits: Vec<u128> = vec![];
    let mut here = 0;
    for l in r.pattern.iter() {
        patbits.push(((1 << l) - 1) << here);
        here += l + 1;
    };
    let mut valid = 0;
    //let width = r.length;
    //println!("free={free}");
    match r.pattern.len() {
        2 => {
            for i in 0..=free {
                for j in i..=free {
                    let this = 
                        patbits[0] << i
                            |
                        patbits[1] << j;
                    if this & r.damaged_mask == r.damaged_mask &&
                        this & r.working_mask == 0 {
                            valid += 1;
                    } else {
                    }
                }
            }
        },
        3 => {
            for i in 0..=free {
                for j in i..=free {
                    for k in j..=free {
                        //println!("({i}, {j}, {k})");
                        let this = 
                            patbits[0] << i
                                |
                            patbits[1] << j
                                |
                            patbits[2] << k;
                        if this & r.damaged_mask == r.damaged_mask &&
                            this & r.working_mask == 0 {
                                //println!("{this:0>width$b} !!!");
                                valid += 1;
                        } else {
                            //println!("{this:0>width$b} ???");
                        }
                    }
                }
            }
        },
        4 => {
            for i in 0..=free {
                for j in i..=free {
                    for k in j..=free {
                        for l in k..=free {
                            //println!("({i},{j},{k},{l}");
                            let this = 
                                patbits[0] << i
                                    |
                                patbits[1] << j
                                    |
                                patbits[2] << k
                                    |
                                patbits[3] << l;
                            if this & r.damaged_mask == r.damaged_mask &&
                                this & r.working_mask == 0 {
                                    //println!("{this:0>width$b} !!!");
                                    valid += 1;
                            } else {
                                //println!("{this:0>width$b} ???");
                            }
                        }
                    }
                }
            }
        },
        5 => {
            for i in 0..=free {
                for j in i..=free {
                    for k in j..=free {
                        for l in k..=free {
                            for m in l..=free {
                                let this = 
                                    patbits[0] << i
                                        |
                                    patbits[1] << j
                                        |
                                    patbits[2] << k
                                        |
                                    patbits[3] << l
                                        |
                                    patbits[4] << m;
                                if this & r.damaged_mask == r.damaged_mask &&
                                    this & r.working_mask == 0 {
                                        //println!("{this:0>width$b} !!!");
                                        valid += 1;
                                } else {
                                    //println!("{this:0>width$b} ???");
                                }
                            }
                        }
                    }
                }
            }
        },
        6 => {
            for i in 0..=free {
                for j in i..=free {
                    for k in j..=free {
                        for l in k..=free {
                            for m in l..=free {
                                for n in m..=free {
                                    let this = 
                                        patbits[0] << i
                                            |
                                        patbits[1] << j
                                            |
                                        patbits[2] << k
                                            |
                                        patbits[3] << l
                                            |
                                        patbits[4] << m
                                            |
                                        patbits[5] << n;
                                    if this & r.damaged_mask == r.damaged_mask &&
                                        this & r.working_mask == 0 {
                                            //println!("{this:0>width$b} !!!");
                                            valid += 1;
                                    } else {
                                        //println!("{this:0>width$b} ???");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        n => panic!("Can't handle {n} spans!"),
    }
    valid
}

fn solvea(filename: &str) -> u64 {
    let records = parse(filename);
    records.iter().map(|r| {
        let num_combos = num_combos_b(r);
        println!("{num_combos} <= {r:?}");
        num_combos
    }).sum()
}
fn num_combos_b(r: &Record) -> u64 {
    let mut spans = vec![Span::new(0)];
    spans.extend(r.pattern.iter().map(|l| Span::new(*l as usize)));
    spans[1].offset = 1;
    //println!("{r:?}");
    let mut i = 1;
    let mut valid = 0;
    while i > 0 {
        //println!("i={i}, spans={spans:?}");
        // If we're RIGHT at the beginning
        if spans[i].offset == 0
            ||
            // OR If we're not RIGHT at the beginning
            // spans[i].offset > 0 && // Don't have to check this as [1].offset always starts at 1
            // AND there is no damage immediately before us
            (r.damaged_mask & (1 << spans[i].offset - 1)) == 0
            // and this span is still within the map we have
            && ((spans[i].offset + spans[i].length) <= r.length)
        {
            // Continue checking
            if spans[i].is_clean(r) {
                if i == spans.len() - 1 {
                    // This is the LAST span, verify the pattern before claiming victory
                    let required_nodamage_mask: u128 =
                        !((1u128 << (spans[i].offset + spans[i].length)) - 1u128);
                    if required_nodamage_mask & r.damaged_mask == 0 {
                        // SUCCESS!
                        valid += 1;
                    }
                    // Whether or not this worked, we should try moving forward
                    spans[i].offset += 1;
                } else {
                    // Set the next span and loop.
                    spans[i+1].offset = spans[i].offset + spans[i].length + 1;
                    i += 1;
                }
            } else {
                // Span is unclean, but we can try moving forward
                spans[i].offset += 1;
            }
        } else {
            i -= 1;
            spans[i].offset += 1;
        }
    }
    valid
}

fn solveb(filename: &str) -> u64 {
    let records: Vec<_> = parse(filename).iter().map(|r| r.fivex()).collect();
    // obviously we can't do the same as part A, because generating
    // all the combinations concretely won't fly. (also the bitstring representation
    // probalby won't work, THOUGH rust does have a u128 type that might be enough)
    // 28s to do take(29) in release giving a likely correct answer 150711353
    // 28s to do take(29) in release with 1-bit-buffer! 150711353
    records.iter().take(29).map(|r| {
    //records.iter().map(|r| {
        let num_combos = num_combos_b(r);
        println!("{num_combos} <= {r:?}");
        num_combos
    }).sum()
}
