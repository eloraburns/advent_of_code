use std::fmt;

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    fn test_explode1() {
        let mut snailnum = parse("[[[[[9,8],1],2],3],4]");
        let did_explode = explode(&mut snailnum);
        assert_eq!(
            snailnum,
            parse("[[[[0,9],2],3],4]")
        );
        assert!(did_explode);
    }

    #[test]
    fn test_explode2() {
        let mut snailnum = parse("[7,[6,[5,[4,[3,2]]]]]");
        let did_explode = explode(&mut snailnum);
        assert_eq!(
            snailnum,
            parse("[7,[6,[5,[7,0]]]]")
        );
        assert!(did_explode);
    }

    #[test]
    fn test_explode3() {
        let mut snailnum = parse("[[6,[5,[4,[3,2]]]],1]");
        let did_explode = explode(&mut snailnum);
        assert_eq!(
            snailnum,
            parse("[[6,[5,[7,0]]],3]")
        );
        assert!(did_explode);
    }

    #[test]
    fn test_explode4() {
        let mut snailnum = parse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]");
        let did_explode = explode(&mut snailnum);
        assert!(did_explode);
        assert_eq!(
            snailnum,
            parse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
        );
    }
}

#[derive(PartialEq)]
pub enum Sym {
    Lb,
    Comma,
    Rb,
    N(usize),
}

#[derive(PartialEq)]
pub struct Snail {
    n: Vec<Sym>,
}

impl std::fmt::Display for Sym {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Sym::Lb => write!(f, "["),
            Sym::Comma => write!(f, ","),
            Sym::Rb => write!(f, "]"),
            Sym::N(n) => write!(f, "{}", n),
        }
    }
}

impl std::fmt::Debug for Sym {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self)
    }
}

impl std::fmt::Display for Snail {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for s in &self.n {
            write!(f, "{}", s)?;
        }
        Ok(())
    }
}

impl std::fmt::Debug for Snail {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self)
    }
}

pub fn parse(input: &str) -> Snail {
    Snail { n:
        input.as_bytes().iter().map(|c| match c {
            b'[' => Sym::Lb,
            b',' => Sym::Comma,
            b']' => Sym::Rb,
            dig => Sym::N((dig - b'0') as usize),
        }).collect()
    }
}

fn explode(snail: &mut Snail) -> bool {
    let mut lvl = 0;
    let mut i = 0;
    while i < snail.n.len() {
        match snail.n[i] {
            Sym::Lb => {
                lvl += 1;
                if lvl == 5 {
                    let ln = &mut snail.n[i+1];
                    assert_eq!(&snail.n[i+2], Sym::Comma);
                    let rn = &mut snail.n[i+3];
                    for ii in (0..i).rev() {
                        if let (Sym::N(old_n), Sym::N(new_n)) = (snail.n[ii], ln) {
                            snail.n[ii] = Sym::N(old_n + *new_n);
                            break;
                        }
                    }
                    for ii in (i+4)..snail.n.len() {
                        if let (Sym::N(old_n), Sym::N(new_n)) = (snail.n[ii], rn) {
                            snail.n[ii] = Sym::N(old_n + *new_n);
                        }
                    }
                    // x [ n , n ] y
                    snail.n[i] = Sym::N(0);
                    // x 0 n , n ] y
                    snail.n.drain((i+1)..(i+5));
                    // x 0 y
                    return true;
                }
            },
            Sym::Rb => lvl -= 1,
            Sym::Comma => (),
            Sym::N(n) => (),
        }
        i += 1;
    }
    false
}