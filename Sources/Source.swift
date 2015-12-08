infix operator /% {associativity right precedence 100 }

public struct Rational {
  private let num: IntMax
  private let den: UIntMax
}

public func /%(lhs: IntMax, rhs: UIntMax) -> Rational {
  if lhs < 0 { return -(-lhs /% rhs) }
  let ulhs = UIntMax(lhs)
  let g = gcd(ulhs,rhs)
  let (n,d) = (ulhs / g, rhs / g)
  return Rational(num: IntMax(n), den: d)
}

public func /%(lhs: Int, rhs: Int) -> Rational {
  return rhs < 0 ? -IntMax(lhs) /% UIntMax(-rhs) : IntMax(lhs) /% UIntMax(rhs)
}

private func gcd<I: protocol<IntegerArithmeticType, IntegerLiteralConvertible>>(x: I, _ y: I) -> I {
  var (a,b) = (x,y)
  while b != 0 { (a,b) = (b,a%b) }
  return a
}

extension Rational: CustomStringConvertible {
  public var description: String {
    if den == 1 { return String(num) }
    return String(num) + " / " + String(den)
  }
}

extension Rational: Equatable {}

public func ==(lhs: Rational, rhs: Rational) -> Bool {
  return lhs.num == rhs.num && lhs.den == rhs.den
}

public func +(lhs: Rational, rhs: Rational) -> Rational {
  let g = gcd(lhs.den, rhs.den)
  let d = (lhs.den * rhs.den) / g
  return (lhs.num * IntMax(rhs.den/g) + rhs.num * IntMax(lhs.den/g)) /% d
}

public func *(lhs: Rational, rhs: Rational) -> Rational {
  return (lhs.num*rhs.num) /% (lhs.den*rhs.den)
}

public func /(lhs: Rational, rhs: Rational) -> Rational {
  if rhs < 0 { return -lhs / -rhs }
  return (lhs.num*IntMax(rhs.den)) /% (lhs.den*UIntMax(rhs.num))
}

public func -(lhs: Rational, rhs: Rational) -> Rational {
  return lhs + -rhs
}

extension Rational: Comparable {}

public func <(lhs: Rational, rhs: Rational) -> Bool {
  switch (lhs.num < 0, rhs.num < 0) {
  case (true ,true ): return -rhs < -lhs
  case (false,true ): return false
  case (true ,false): return true
  case (false,false): return lhs.num * IntMax(rhs.den) < rhs.num * IntMax(lhs.den)
  }
}

extension Rational: IntegerLiteralConvertible {
  public init(integerLiteral value: IntMax) {
    self.init(num: value, den: 1)
  }
}

extension Rational: SignedNumberType {}

public prefix func -(x: Rational) -> Rational {
  return Rational(num: -x.num, den: x.den)
}

extension Rational: Strideable {
  public func distanceTo(other: Rational) -> Rational {
    return other - self
  }
  public func advancedBy(n: Rational) -> Rational {
    return self + n
  }
}

extension Rational {
  public var double: Double {
    return Double(num) / Double(den)
  }
}
