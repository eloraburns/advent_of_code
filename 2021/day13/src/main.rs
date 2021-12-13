use std::collections::HashSet;

fn main() {
    let input = std::fs::read_to_string("input.txt").unwrap();
    let mut input_parts = input.split("\n\n");

    if false {
        let dots: HashSet<(usize,usize)> = input_parts.next().unwrap().lines()
            .map(|l| {
                let mut parts = l.split(",");
                (parts.next().unwrap().parse().unwrap(), parts.next().unwrap().parse().unwrap())
            })
            .collect();
        let folds: Vec<(char, usize)> = input_parts.next().unwrap().lines()
            .map(|l| {
                (
                    l.chars().nth(11).unwrap(),
                    l[13..].parse().unwrap()
                )
            })
            .collect();
        let first_fold = folds.first().unwrap();

        let folded: HashSet<(usize,usize)> = dots
            .iter()
            .map(|(x, y)| {
                match first_fold.0 {
                    'x' => {
                        if *x > first_fold.1 {
                            (first_fold.1 * 2 - x, *y)
                        } else {
                            (*x, *y)
                        }
                    },
                    'y' => {
                        (*x, *y)
                    },
                    wat => {
                        panic!("unknown fold type {}", wat)
                    }
                }
                
            })
            .collect();

        println!("13a(input): {}", folded.len());

    } else {
        let mut dots: Vec<(usize,usize)> = input_parts.next().unwrap().lines()
            .map(|l| {
                let mut parts = l.split(",");
                (parts.next().unwrap().parse().unwrap(), parts.next().unwrap().parse().unwrap())
            })
            .collect();
        let folds: Vec<(char, usize)> = input_parts.next().unwrap().lines()
            .map(|l| {
                (
                    l.chars().nth(11).unwrap(),
                    l[13..].parse().unwrap()
                )
            })
            .collect();

        for (fold_axis, fold_ordinate) in folds {
            if fold_axis == 'x' {
                dots = dots.iter().map(|(x, y)| {
                    if *x > fold_ordinate {
                        (fold_ordinate * 2 - x, *y)
                    } else {
                        (*x, *y)
                    }
                }).collect();
            } else {
                dots = dots.iter().map(|(x, y)| {
                    if *y > fold_ordinate {
                        (*x, fold_ordinate * 2 - y)
                    } else {
                        (*x, *y)
                    }
                }).collect();
            }
        }
        for y in 0..6 {
            for x in 0..40 {
                if dots.contains(&(x, y)) {
                    print!("*");
                } else {
                    print!(" ");
                }
            }
            println!();
        }
    }

}