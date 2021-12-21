use std::ops::Range;

fn main() {
    // target area: x=20..30, y=-10..-5
    let test_xr = 20..31;
    let test_yr = -10..-4;
    let test_dxr = 6..31;
    let test_dyr = -10..10;
    println!("17a(test; expect 45): {}", solvea(test_yr.clone()));
    println!("17b(test; expect 112): {}", solveb(test_xr, test_yr, test_dxr, test_dyr));

    // target area: x=34..67, y=-215..-186
    let xr = 34..68;
    let yr = -215..-185;
    // 23005
    let dxr = 8..68;
    let dyr = -215..215;
    println!("17a(input): {}", solvea(yr.clone()));
    // 2040
    println!("17b(input): {}", solveb(xr, yr, dxr, dyr));
}

fn solvea(target_y: Range<i32>) -> usize {
    if target_y.start < 0 {
        (0..((-target_y.start) as usize)).sum()
    } else {
        panic!("I don't know how to solve this for positive target zone!");
    }
}

fn solveb(xr: Range<i32>, yr: Range<i32>, dxr: Range<i32>, dyr: Range<i32>) -> usize {
    let mut got_target = 0;
    for idx in dxr {
        for idy in dyr.clone() {
            let (mut dx, mut dy, mut x, mut y) = (idx, idy, idx, idy);
            while y >= dyr.start {
                if xr.contains(&x) && yr.contains(&y) {
                    got_target += 1;
                    break;
                }
                dx = std::cmp::max(0, dx - 1);
                dy -= 1;
                x += dx;
                y += dy;
            }
        }
    }

    return got_target;
}