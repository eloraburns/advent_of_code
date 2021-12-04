use std::fs;

const WIDTH: usize = 12;
const MASK: u32 = (1 << WIDTH) - 1;

fn main() {
    let contents = fs::read_to_string("input.txt")
        .expect("can't read file");
    
    let nums: Vec<u32> = contents.lines()
        .map(|l| u32::from_str_radix(l, 2).unwrap())
        .collect();
    
    println!("3a: {}", solve3a(&nums));
    println!("3b: {}", solve3b(&nums));

}

fn solve3a(nums: &Vec<u32>) -> u32 {
    let mut onecounts = vec![0; WIDTH];

    for num in nums {
        for i in 0..WIDTH {
            if (1 << i) & num != 0 {
                onecounts[i] += 1;
            }
        }
    }

    let mut gr = 0;
    for i in 0..WIDTH {
        if onecounts[i] > (nums.len() >> 1) {
            gr |= 1 << i;
        }
    }

    let er = gr ^ MASK;
    return gr * er;
}

fn solve3b(nums: &Vec<u32>) -> u32 {
    let mut ogrl = nums.clone();
    for ii in 0..WIDTH {
        // Exit if we've found the one value
        if ogrl.len() == 1 {
            break;
        }
        // The bit offset (0-based, starting at the MSB)
        let i = WIDTH - 1 - ii;
        // Count the number of ones in this bit position
        let mut ones = 0;
        for num in &ogrl {
            if (1 << i) & num != 0 {
                ones += 1;
            }
        }
        // Create a mask and value for the bit in question
        let this_mask: u32 = 1 << i;
        let mut this_bit: u32 = 0;
        if ones >= ((ogrl.len()+1) >> 1) {
            this_bit = this_mask;
        };
        // Remove all the values that don't match
        let mut j = 0;
        while j < ogrl.len() {
            if (ogrl[j] & this_mask) ^ this_bit == 0 {
                // The XOR is 0, meaning it's a match; carry on.
                j += 1;
            } else {
                // The XOR is 1, meaning it's not a match; remove this element.
                // As it'll get replaced by the last element, we do NOT advance j.
                ogrl.swap_remove(j);
            }
        }
    }
    let ogr = ogrl[0];

    let mut co2l = nums.clone();
    for ii in 0..WIDTH {
        // Exit if we've found the one value
        if co2l.len() == 1 {
            break;
        }
        // The bit offset (0-based, starting at the MSB)
        let i = WIDTH - 1 - ii;
        // Count the number of ones in this bit position
        let mut ones = 0;
        for num in &co2l {
            if (1 << i) & num != 0 {
                ones += 1;
            }
        }
        // Create a mask and value for the bit in question
        let this_mask: u32 = 1 << i;
        let mut this_bit: u32 = 0;
        if ones < ((co2l.len()+1) >> 1) {
            this_bit = this_mask;
        };
        // Remove all the values that don't match
        let mut j = 0;
        while j < co2l.len() {
            if (co2l[j] & this_mask) ^ this_bit == 0 {
                // The XOR is 0, meaning it's a match; carry on.
                j += 1;
            } else {
                // The XOR is 1, meaning it's not a match; remove this element.
                // As it'll get replaced by the last element, we do NOT advance j.
                co2l.swap_remove(j);
            }
        }
    }
    let co2 = co2l[0];
    println!("ogr={}, co2={}", ogr, co2);
    return ogr * co2;
}