use std::collections::HashMap;
use std::fs;

#[derive(Debug,Eq,PartialEq,Ord,PartialOrd)]
enum HandType {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind
}

impl HandType {
    fn determinea(s: &str) -> HandType {
        let mut counts = HashMap::new();
        for ch in s.chars() {
            let co = match counts.get(&ch) {
                Some(co) => *co,
                None => 0
            };
            counts.insert(ch, co + 1);
        }
        let mut mags: Vec<_> = counts.values().collect();
        mags.sort();
        mags.reverse();
        if *mags[0] == 5 {
            HandType::FiveOfAKind
        } else if *mags[0] == 4 {
            HandType::FourOfAKind
        } else if *mags[0] == 3 && *mags[1] == 2 {
            HandType::FullHouse
        } else if *mags[0] == 3 {
            HandType::ThreeOfAKind
        } else if *mags[0] == 2 && *mags[1] == 2 {
            HandType::TwoPair
        } else if *mags[0] == 2 {
            HandType::OnePair
        } else {
            HandType::HighCard
        }
    }

    fn determineb(s: &str) -> HandType {
        let mut counts = HashMap::new();
        let mut jokers = 0;
        for ch in s.chars() {
            if ch == 'J' {
                jokers += 1;
            } else {
                let co = match counts.get(&ch) {
                    Some(co) => *co,
                    None => 0
                };
                counts.insert(ch, co + 1);
            }
        }

        // This is a fun edge case!
        if jokers == 5 {
            return HandType::FiveOfAKind;
        }

        let mut mags: Vec<_> = counts.values().collect();
        mags.sort();
        mags.reverse();
        if *mags[0] + jokers == 5 {
            HandType::FiveOfAKind
        } else if *mags[0] + jokers == 4 {
            HandType::FourOfAKind
        } else if *mags[0] + jokers == 3 && *mags[1] == 2 {
            HandType::FullHouse
        } else if *mags[0] + jokers == 3 {
            HandType::ThreeOfAKind
        } else if *mags[0] == 2 && *mags[1] == 2 {
            HandType::TwoPair
        } else if *mags[0] + jokers == 2 {
            HandType::OnePair
        } else {
            HandType::HighCard
        }
    }
}

#[derive(Debug,Eq,PartialEq,Ord,PartialOrd)]
struct Hand {
    hand_type: HandType,
    hand: [u64; 5],
    bid: u64
}

fn main() {
    println!("Test a (6440): {}", solvea("testa.txt"));
    println!("Solve a (253313241): {}", solvea("input.txt"));
    println!("Test b (5905): {}", solveb("testa.txt"));
    println!("Solve b (253362743): {}", solveb("input.txt"));
}

fn parsea(filename: &str) -> Vec<Hand> {
    let contents = fs::read_to_string(filename).expect("can't read file");
    contents.lines().map(|l| {
        let mut s = l.split_whitespace();
        let hand = s.next().unwrap();
        let bid = s.next().unwrap().parse::<u64>().unwrap();
        Hand {
            hand_type: HandType::determinea(hand),
            hand: hand.chars().map(|c| match c {
                '2' => 2,
                '3' => 3,
                '4' => 4,
                '5' => 5,
                '6' => 6,
                '7' => 7,
                '8' => 8,
                '9' => 9,
                'T' => 10,
                'J' => 11,
                'Q' => 12,
                'K' => 13,
                'A' => 14,
                _ => panic!("Unknown card {}", c)
            }).collect::<Vec<u64>>().try_into().unwrap(),
            bid: bid
        }
    }).collect()
}

fn solvea(filename: &str) -> u64 {
    let mut hands = parsea(filename);
    hands.sort();
    hands.iter().enumerate().map(|(rank_minus_one, hand)| {
        //println!("{}: {:?}", rank_minus_one + 1, hand);
        (rank_minus_one as u64 + 1) * hand.bid
    }
    ).sum()
}

fn parseb(filename: &str) -> Vec<Hand> {
    let contents = fs::read_to_string(filename).expect("can't read file");
    contents.lines().map(|l| {
        let mut s = l.split_whitespace();
        let hand = s.next().unwrap();
        let bid = s.next().unwrap().parse::<u64>().unwrap();
        Hand {
            hand_type: HandType::determineb(hand),
            hand: hand.chars().map(|c| match c {
                '2' => 2,
                '3' => 3,
                '4' => 4,
                '5' => 5,
                '6' => 6,
                '7' => 7,
                '8' => 8,
                '9' => 9,
                'T' => 10,
                'J' => 1,
                'Q' => 12,
                'K' => 13,
                'A' => 14,
                _ => panic!("Unknown card {}", c)
            }).collect::<Vec<u64>>().try_into().unwrap(),
            bid: bid
        }
    }).collect()
}

fn solveb(filename: &str) -> u64 {
    let mut hands = parseb(filename);
    hands.sort();
    hands.iter().enumerate().map(|(rank_minus_one, hand)| {
        //println!("{}: {:?}", rank_minus_one + 1, hand);
        (rank_minus_one as u64 + 1) * hand.bid
    }
    ).sum()
}
