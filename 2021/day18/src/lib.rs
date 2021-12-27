use std::fmt;

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    fn test_equality() {
        assert_eq!(S::N(1), S::N(1));
        assert_ne!(S::N(1), S::N(2));
        assert_eq!(
            S::P(Box::new(S::N(1)), Box::new(S::N(2))),
            S::P(Box::new(S::N(1)), Box::new(S::N(2))));
        assert_ne!(
            S::P(Box::new(S::N(1)), Box::new(S::N(2))),
            S::P(Box::new(S::N(2)), Box::new(S::N(2))));
        assert_ne!(
            S::P(Box::new(S::N(1)), Box::new(S::N(2))),
            S::N(3));
    }

    #[test]
    fn test_parse() {
        assert_eq!(*parse("1"), S::N(1));
        assert_eq!(*parse("[1,2]"), S::P(Box::new(S::N(1)), Box::new(S::N(2))));
        assert_eq!(
            *parse("[[[1,[2,3]],4],5]"),
            S::P(
                Box::new(S::P(
                    Box::new(S::P(
                        Box::new(S::N(1)),
                        Box::new(S::P(
                            Box::new(S::N(2)),
                            Box::new(S::N(3))
                        ))
                    )),
                    Box::new(S::N(4))
                )),
                Box::new(S::N(5))
            )
        );
    }

    #[test]
    fn test_explode1() {
        let mut snailnum = parse("[[[[[9,8],1],2],3],4]");
        let residue = explode(&mut *snailnum, 0);
        assert_eq!(residue, (Some(9), None));
        assert_eq!(
            snailnum,
            parse("[[[[0,9],2],3],4]")
        );
    }

    #[test]
    fn test_explode2() {
        let mut snailnum = parse("[7,[6,[5,[4,[3,2]]]]]");
        let residue = explode(&mut *snailnum);
        assert_eq!(residue, (None, Some(2)));
        assert_eq!(
            snailnum,
            parse("[7,[6,[5,[7,0]]]]")
        );
    }

    #[test]
    fn test_explode3() {
        let mut snailnum = parse("[[6,[5,[4,[3,2]]]],1]");
        let residue = explode(&mut *snailnum);
        assert_eq!(residue, (None, None));
        assert_eq!(
            snailnum,
            parse("[[6,[5,[7,0]]],3]")
        );
    }

    #[test]
    fn test_explode4() {
        let mut snailnum = parse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]");
        let residue = explode(&mut *snailnum);
        assert_eq!(residue, (Some(9), None));
        assert_eq!(
            snailnum,
            parse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
        );
    }
}

#[derive(PartialEq,Clone)]
pub enum S {
    P(Box<S>, Box<S>),
    N(usize),
}

impl fmt::Display for S {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            S::P(a, b) => write!(f, "[{},{}]", a, b),
            S::N(n) => write!(f, "{}", n),
        }
    }
}

impl fmt::Debug for S {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self)
    }
}

pub fn parse(input: &str) -> Box<S> {
    parse_internal(input.as_bytes(), &mut 0)
}

fn require_at(input: &[u8], i: &mut usize, c: u8) {
    if input[*i] != c {
        panic!("Expected {}, found {} at i={}", c, input[*i], *i);
    }
    *i += 1;
}

fn parse_internal<'a>(input: &[u8], i: &mut usize) -> Box<S> {
    *i += 1;
    match input[*i - 1] {
        b'[' => {
            let a = parse_internal(input, i);
            require_at(input, i, b',');
            let b = parse_internal(input, i);
            require_at(input, i, b']');
            Box::new(S::P(a, b))
        },
        c => {
            Box::new(S::N((c - b'0') as usize))
        },
    }
}

pub fn explode(s: &mut S) -> bool {
    loop {
        let mut root = Box::new(s);
        let (_, exploded, _) = check_explode(&mut root, 0);
        if !exploded {
            return exploded;
        }
    }
}

fn check_explode(s: &mut Box<&mut S>, level: usize) -> (Option<usize>, bool, Option<usize>) {
    match s {
        S::N(_) => (None, None),
        S::P(a, b) => {
            if level == 4 {
                s = S::N(0);
                (Some(a), Some(b))
            } else {
                let (la, lexploded, lb) = check_explode(a, level + 1);
                if lexploded && matches!(lb, Some(_)) {
                    let (ia, ib) = do_explode(lb, b, None);
                    return (la, true, ib);
                }
                let (ra, rexploded, rb) = check_explode(b, level + 1);
                (la, rb)
            }
        }
    }
}