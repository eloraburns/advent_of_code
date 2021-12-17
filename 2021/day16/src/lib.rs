

#[derive(Debug)]
pub struct State<'a> {
    bitstream: &'a Vec<u8>,
    current: usize,
    pub version_sum: usize,
    last_literal: usize,
    pub value: usize,
}

pub fn str_to_bitstream(contents: &str) -> Vec<u8> {
    contents
        .chars()
        .flat_map(|c| {
            match c {
                '0' => vec![0, 0, 0, 0],
                '1' => vec![0, 0, 0, 1],
                '2' => vec![0, 0, 1, 0],
                '3' => vec![0, 0, 1, 1],
                '4' => vec![0, 1, 0, 0],
                '5' => vec![0, 1, 0, 1],
                '6' => vec![0, 1, 1, 0],
                '7' => vec![0, 1, 1, 1],
                '8' => vec![1, 0, 0, 0],
                '9' => vec![1, 0, 0, 1],
                'A' => vec![1, 0, 1, 0],
                'B' => vec![1, 0, 1, 1],
                'C' => vec![1, 1, 0, 0],
                'D' => vec![1, 1, 0, 1],
                'E' => vec![1, 1, 1, 0],
                'F' => vec![1, 1, 1, 1],
                _ => vec![],
            }
        })
        .collect()
}

pub fn parse<'a>(b: &'a Vec<u8>) -> State<'a> {
    let mut state: State = State {
        bitstream: b,
        current: 0,
        version_sum: 0,
        last_literal: 0,
        value: 0,
    };

    state.value = parse_packet(&mut state);

    state
}

fn slurp(s: &mut State, bits: usize) -> usize {
    let mut acc = 0;
    for _ in 0..bits {
        acc <<= 1;
        acc += s.bitstream[s.current] as usize;
        s.current += 1;
    }
    acc
}

fn parse_packet(s: &mut State) -> usize {
    match (slurp(s, 3), slurp(s, 3)) {
        (v, 4) => {
            s.version_sum += v;
            s.last_literal = parse_literal(s, 0);
            s.last_literal
        }
        (v, type_num) => {
            s.version_sum += v;
            parse_operator(s, type_num)
        }
    }
}

fn parse_literal(s: &mut State, acc: usize) -> usize {
    let not_done = slurp(s, 1);
    let four_bits = slurp(s, 4);
    if not_done > 0 {
        parse_literal(s, (acc << 4) + (four_bits as usize))
    } else {
        (acc << 4) + (four_bits as usize)
    }
}

fn parse_operator(s: &mut State, type_num: usize) -> usize {
    let mut subs: Vec<usize> = Vec::new();
    if slurp(s, 1) == 0 {
        let bits_to_read = slurp(s, 15);
        let now = s.current;
        while s.current < now + bits_to_read {
            subs.push(parse_packet(s));
        }
    } else {
        let packets_to_read = slurp(s, 11);
        for _ in 0..packets_to_read {
            subs.push(parse_packet(s));
        }
    }
    match type_num {
        0 => { // sum
            subs.iter().sum()
        }
        1 => { // product
            subs.iter().product()
        }
        2 => { // min
            *subs.iter().min().unwrap()
        }
        3 => { // max
            *subs.iter().max().unwrap()
        }
        4 => {
            panic!("read literal as if it were an operator?!")
        }
        5 => { // gt
            (subs[0] > subs[1]) as usize
        }
        6 => { // lt
            (subs[0] < subs[1]) as usize
        }
        7 => { // eq
            (subs[0] == subs[1]) as usize
        }
        other => {
            panic!("wtf did we get {}", other)
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        let s = "0123456789ABCDEF";
        let e: Vec<u8> = (0..16).flat_map(|i| [(i & 0x8) >> 3, (i & 0x4) >> 2, (i & 0x2) >> 1, i & 0x1]).collect();
        assert_eq!(str_to_bitstream(s), e);
    }

    #[test]
    fn test_literal() {
        let b = str_to_bitstream("D2FE28");
        let s = parse(&b);
        assert_eq!(s.version_sum, 6);
        assert_eq!(s.last_literal, 2021);
    }

    #[test]
    fn test_bitlength_opcode() {
        let b = str_to_bitstream("38006F45291200");
        let s = parse(&b);
        assert_eq!(s.version_sum, 0b001 + 0b110 + 0b010);
    }

    #[test]
    fn test_packetlength_opcode() {
        let b = str_to_bitstream("EE00D40C823060");
        let s = parse(&b);
        assert_eq!(s.version_sum, 0b111 + 0b010 + 0b100 + 0b001);
    }

    #[test]
    fn test_examples() {
        let cases = vec![
            ("8A004A801A8002F478", 16),
            ("620080001611562C8802118E34", 12),
            ("C0015000016115A2E0802F182340", 23),
            ("A0016C880162017C3686B18A3D4780", 31),            
        ];
        for (hex, expected) in cases {
            let b = str_to_bitstream(hex);
            assert_eq!(parse(&b).version_sum, expected);
        }
    }
}