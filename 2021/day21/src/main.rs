fn main() {
    // Player 1 starting position: 7
    // Player 2 starting position: 2

    println!("21a(test; expect 739785): {}", solvea(4, 8));
    println!("21a(input): {}", solvea(7, 2));
}

fn solvea(player_1_start: usize, player_2_start: usize) -> usize {
    let mut die_rolls = 0usize;
    let mut die_value = 1usize;
    let mut p1_loc = player_1_start;
    let mut p2_loc = player_2_start;
    let mut p1_score = 0usize;
    let mut p2_score = 0usize;

    while p2_score < 1000 {
        let mut p1_roll = 0usize;
        for _ in  0..3 {
            p1_roll += die_value;
            die_value = (die_value % 100) + 1;
        }
        die_rolls += 3;
        p1_loc = (p1_loc + p1_roll) % 10;
        if p1_loc == 0 { p1_loc = 10; }
        p1_score += p1_loc;
        if p1_score >= 1000 {
            break;
        }
        let mut p2_roll = 0usize;
        for _ in  0..3 {
            p2_roll += die_value;
            die_value = (die_value % 100) + 1;
        }
        die_rolls += 3;
        p2_loc = (p2_loc + p2_roll) % 10;
        if p2_loc == 0 { p2_loc = 10; }
        p2_score += p2_loc;
    }

    return std::cmp::min(p1_score, p2_score) * die_rolls;
}
