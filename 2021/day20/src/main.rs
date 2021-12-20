use std::collections::HashMap;
use std::cmp::{min, max};
use std::ops::Range;

fn main() {
    println!("20a(test, expect 35): {}", solvea("test.txt"));
    println!("20b(test, expect 3351): {}", solveb("test.txt"));

    // 5026 is too high
    // it's 4928
    println!("20a(input): {}", solvea("input.txt"));
    // 17365 is too high
    // it's 16605
    println!("20b(input): {}", solveb("input.txt"));
}

fn parse(filename: &str) -> (Vec<bool>, HashMap<(i32, i32), bool>) {
    let input = std::fs::read_to_string(filename).unwrap();
    let mut parts = input.split("\n\n");
    let rules = parts.next().unwrap().chars().map(|c| c == '#').collect();
    let view = parts.next().unwrap().lines().enumerate().flat_map(|(y, line)| -> Vec<((i32, i32), bool)> {
        line.chars().enumerate().map(|(x, c)| ((x as i32, y as i32), c == '#')).collect()
    }).collect();

    (rules, view)
}

fn solvea(filename: &str) -> usize {
    let (rules, view) = parse(filename);
    let (xr, yr) = bounds(&view);
    // print_view(&view);
    let step1 = step(&rules, &view, widen(&xr, 10), widen(&yr, 10));
    // print_view(&step1);
    let step2 = step(&rules, &step1, widen(&xr, 10), widen(&yr, 10));
    // print_view(&step2);
    pop(&step2, widen(&xr, 2), widen(&yr, 2))
}

fn solveb(filename: &str) -> usize {
    let (rules, mut view) = parse(filename);
    let (xr, yr) = bounds(&view);
    for _ in 0..50 {
        view = step(&rules, &view, widen(&xr, 110), widen(&yr, 110));
    }
    pop(&view, widen(&xr, 52), widen(&yr, 52))
}

fn widen(r: &Range<i32>, by: i32) -> Range<i32> {
    (r.start - by)..(r.end + by)
}

fn bounds(view: &HashMap<(i32, i32), bool>) -> (Range<i32>, Range<i32>) {
    let (ix, iy, ax, ay) = view
        .iter()
        .fold((i32::MAX, i32::MAX, i32::MIN, i32::MIN), |(ix, iy, ax, ay), ((x, y), c)| {
            if *c {
                (min(ix, *x), min(iy, *y), max(ax, *x), max(ay, *y))
            } else {
                (ix, iy, ax, ay)
            }
        });
    ((ix-1)..(ax+2), (iy-1)..(ay+2))
}

fn pop(view: &HashMap<(i32, i32), bool>, xr: Range<i32>, yr: Range<i32>) -> usize {
    view.iter().filter(|((x, y), c)| **c && xr.contains(&x) && yr.contains(&y)).count()
}

fn print_view(view: &HashMap<(i32, i32), bool>) {
    let (xr, yr) = bounds(view);
    println!("========");
    for y in yr {
        for x in xr.clone() {
            if *view.get(&(x, y)).unwrap_or(&false) {
                print!("#");
            } else {
                print!(".");
            }
        }
        println!();
    }
}

fn step(rules: &Vec<bool>, view: &HashMap<(i32, i32), bool>, xr: Range<i32>, yr: Range<i32>) -> HashMap<(i32, i32), bool> {
    xr.flat_map(|x| {
        yr.clone().map(move |y| {
            let bit8 = *view.get(&(x-1, y-1)).unwrap_or(&false) as usize;
            let bit7 = *view.get(&(x  , y-1)).unwrap_or(&false) as usize;
            let bit6 = *view.get(&(x+1, y-1)).unwrap_or(&false) as usize;
            let bit5 = *view.get(&(x-1, y  )).unwrap_or(&false) as usize;
            let bit4 = *view.get(&(x  , y  )).unwrap_or(&false) as usize;
            let bit3 = *view.get(&(x+1, y  )).unwrap_or(&false) as usize;
            let bit2 = *view.get(&(x-1, y+1)).unwrap_or(&false) as usize;
            let bit1 = *view.get(&(x  , y+1)).unwrap_or(&false) as usize;
            let bit0 = *view.get(&(x+1, y+1)).unwrap_or(&false) as usize;
            let rule = (bit8 << 8) + (bit7 << 7) + (bit6 << 6) + (bit5 << 5)
                + (bit4 << 4) + (bit3 << 3) + (bit2 << 2) + (bit1 << 1) + bit0;

            ((x, y), rules[rule])
        })
        .filter(|(_, c)| *c)
    }).collect()
}