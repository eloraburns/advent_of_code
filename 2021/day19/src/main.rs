use std::collections::BTreeSet;

fn main() {
    let test_fitted = fit("test.txt");
    println!("19a(test; expect 79): {}", solvea(&test_fitted));
    println!("19b(test; expect 3621): {}", solveb(&test_fitted));

    let input_fitted = fit("input.txt");
    println!("19a(input): {}", solvea(&input_fitted));
    println!("19b(input): {}", solveb(&input_fitted));
}

fn fit(filename: &str) -> Vec<Scanner> {
    let mut scanners_to_fit = parse(filename);
    let mut fitted_scanners = vec![scanners_to_fit.swap_remove(1)];
    let mut fs = 0usize;
    while !scanners_to_fit.is_empty() {
        let anchor = &fitted_scanners[fs].clone();
        let mut stf = 0;
        'next_scanner: while stf < scanners_to_fit.len() {
            let candidate = &scanners_to_fit[stf];
            for candidate_beacon in &candidate.beacons {
                let reorientations = rotations(&recentre(candidate, &candidate_beacon));
                for anchor_beacon in &anchor.beacons {
                    let boop: Vec<_> = reorientations.iter().map(|s| translate(s, &anchor_beacon)).collect();
                    for reo in &boop {
                        if anchor.beacons.intersection(&reo.beacons).cloned().collect::<Vec<Coord>>().len() >= 12 {
                            scanners_to_fit.swap_remove(stf);
                            fitted_scanners.push(reo.clone());
                            continue 'next_scanner;
                        }
                    }
                }
            }
            stf += 1;
        }
        fs += 1;
    }
    fitted_scanners
}

fn solvea(fitted: &Vec<Scanner>) -> usize {
    fitted
        .iter()
        .fold(BTreeSet::new(), |acc, a| acc.union(&a.beacons).cloned().collect())
        .len()
}

fn solveb(fitted: &Vec<Scanner>) -> usize {
    let mut distances = vec![];
    for i in 0..fitted.len() {
        for j in i..fitted.len() {
            let (a, b) = (&fitted[i], &fitted[j]);
            distances.push(
                (a.scanner.x - b.scanner.x).abs()
                + (a.scanner.y - b.scanner.y).abs()
                + (a.scanner.z - b.scanner.z).abs()
            );
        }
    }
    *distances.iter().reduce(|a, b| a.max(b)).unwrap() as usize
}

#[derive(Debug,Ord,Eq,PartialOrd,PartialEq,Clone)]
struct Coord {
    x: i32,
    y: i32,
    z: i32,
}

#[derive(Debug,Clone)]
struct Scanner {
    scanner: Coord,
    beacons: BTreeSet<Coord>
}

fn recentre(scanner: &Scanner, locus: &Coord) -> Scanner {
    Scanner {
        scanner: Coord { x: scanner.scanner.x - locus.x, y: scanner.scanner.y - locus.y, z: scanner.scanner.z - locus.z },
        beacons: scanner.beacons.iter().map(|c|
            Coord { x: c.x - locus.x, y: c.y - locus.y, z: c.z - locus.z }
        ).collect::<BTreeSet<Coord>>()
    }
}

fn rotations(scanner: &Scanner) -> Vec<Scanner> {
    vec![
        scanner.clone(),
        Scanner {
            scanner: Coord { x: scanner.scanner.x, y: scanner.scanner.z, z: -scanner.scanner.y },
            beacons: scanner.beacons.iter().map(|c| Coord { x:  c.x, y:  c.z, z: -c.y }).collect() },
        Scanner {
            scanner: Coord { x: scanner.scanner.x, y: -scanner.scanner.y, z: -scanner.scanner.z },
            beacons: scanner.beacons.iter().map(|c| Coord { x:  c.x, y: -c.y, z: -c.z }).collect() },
        Scanner {
            scanner: Coord { x: scanner.scanner.x, y: -scanner.scanner.z, z: scanner.scanner.y },
            beacons: scanner.beacons.iter().map(|c| Coord { x:  c.x, y: -c.z, z:  c.y }).collect() },
        Scanner {
            scanner: Coord { x: scanner.scanner.z, y: scanner.scanner.y, z: -scanner.scanner.x },
            beacons: scanner.beacons.iter().map(|c| Coord { x:  c.z, y:  c.y, z: -c.x }).collect() },
        Scanner {
            scanner: Coord { x: -scanner.scanner.z, y: scanner.scanner.y, z: scanner.scanner.x },
            beacons: scanner.beacons.iter().map(|c| Coord { x: -c.z, y:  c.y, z:  c.x }).collect() },
    ].into_iter().flat_map(|s| {
        vec![
            s.clone(),
            Scanner {
                scanner: Coord { x: s.scanner.y, y: -s.scanner.x, z: s.scanner.z },
                beacons: s.beacons.iter().map(|c| Coord { x:  c.y, y: -c.x, z:  c.z }).collect() },
            Scanner {
                scanner: Coord { x: -s.scanner.x, y: -s.scanner.y, z: s.scanner.z },
                beacons: s.beacons.iter().map(|c| Coord { x: -c.x, y: -c.y, z:  c.z }).collect() },
            Scanner {
                scanner: Coord { x: -s.scanner.y, y: s.scanner.x, z: s.scanner.z },
                beacons: s.beacons.iter().map(|c| Coord { x: -c.y, y:  c.x, z:  c.z }).collect() },
        ]
    })
    .collect()
}

fn translate(scanner: &Scanner, locus: &Coord) -> Scanner {
    Scanner {
        scanner: Coord { x: scanner.scanner.x + locus.x, y: scanner.scanner.y + locus.y, z: scanner.scanner.z + locus.z },
        beacons: scanner.beacons.iter().map(|c|
            Coord { x: c.x + locus.x, y: c.y + locus.y, z: c.z + locus.z }
        ).collect::<BTreeSet<Coord>>()
    }
}

fn parse(filename: &str) -> Vec<Scanner> {
    let contents = std::fs::read_to_string(filename).unwrap();
    contents
        .split("\n\n")
        .map(|s| Scanner {
            scanner: Coord { x: 0, y: 0, z: 0},
            beacons: s.lines()
                .filter_map(|l| match &l[0..3] {
                    "---" => None,
                    _ => {
                        let coords: Vec<_> = l.split(",").map(|c| c.parse().unwrap()).collect();
                        Some(Coord { x: coords[0], y: coords[1], z: coords[2] })
                    },
                })
                .collect()
        })
        .collect()
}