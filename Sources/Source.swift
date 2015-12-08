infix operator /% {associativity right precedence 100 }

/// A rational number type, which stores the numerator and denominator
/// for a fraction. 
///
/// The only exposed initialiser for the struct automatically simplifies
/// before storing. The user cannot manually adjust the numerator and
/// denominator. This ensures that the fraction is always stored in its 
/// simplest form:
///
/// ```swift
/// String(6 /% 8) == 3/4
/// ```
///
/// The numerator is stored as the maximum-sized signed integer type, 
/// and the denominator is stored as the maximum-sized unsigned integer
/// type.

public struct Rational {
  public let num: IntMax
  public let den: UIntMax
}

extension Rational {
  public init(_ num: IntMax, _ den: UIntMax) {
    let unum = UIntMax(abs(num))
    let g = gcd(unum,den)
    let n = unum / g
    self.num = num < 0 ? -IntMax(n) : IntMax(n)
    self.den = den / g
  }
  public init(_ n: Int) {
    num = IntMax(n)
    den = 1
  }
}

public func /%(lhs: IntMax, rhs: UIntMax) -> Rational {
  return Rational(lhs,rhs)
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
    return String(num) + "/" + String(den)
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
  case (false,false): return UIntMax(lhs.num) * rhs.den < UIntMax(rhs.num) * lhs.den
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
  
  /// The `Double` representation of `self`.
  
  public var double: Double {
    return Double(num) / Double(den)
  }
}

extension Rational {
  
  /// The reciprocal of self
  ///
  /// ```swift
  /// String((3 /% 4).reciprocal) == 4/3
  /// ```
  
  public var reciprocal: Rational {
    if num < 0 {
      return Rational(num: -IntMax(den), den: UIntMax(abs(num)))
    } else {
      return Rational(num: IntMax(den), den: UIntMax(num))
    }
  }
}
