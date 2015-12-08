import XCTest
import Darwin
import Rational

private func closeEnough(a: Rational, _ b: Double) -> Bool {
  return abs(a.double-b) < 0.0001
}

private protocol Randable {
  static var rand: Self { get }
}

extension UInt32: Randable {
  static var rand: UInt32 {
    return arc4random_uniform(UInt32.max)
  }
}

extension IntMax: Randable {
  static var rand: IntMax {
    return (IntMax(UInt32.rand) << 32) | IntMax(UInt32.rand)
  }
}

extension UIntMax: Randable {
  static var rand: UIntMax {
    return (UIntMax(UInt32.rand) << 32) | UIntMax(UInt32.rand)
  }
}

extension Rational: Randable {
  static var rand: Rational {
    let d = UIntMax.rand >> 50
    let n = IntMax.rand / (1 << 50)
    return (n == 0 ? 1 : n) /% (d == 0 ? 1 : d)
  }
}

extension Rational {
  /// A property which tests if the fraction is in its simplest form.
  /// Should always be `true`.
  private var isSimplest: Bool {
    var (a,b) = (UIntMax(abs(num)), den)
    while b != 0 { (a,b) = (b,a%b) }
    return a == 1
  }
}

let n = 1000

class RationalTests: XCTestCase {
  func testDoubleEquiv() {
    for _ in 0..<n {
      let (a,b) = (IntMax.rand,IntMax.rand)
      let (c,d) = (UIntMax.rand,UIntMax.rand)
      let ac = a /% c
      let bd = b /% d
      XCTAssert(ac.isSimplest)
      XCTAssert(bd.isSimplest)
      let acd = Double(a) / Double(c)
      let bdd = Double(b) / Double(d)
      XCTAssert(closeEnough(ac, acd))
      XCTAssert(closeEnough(bd, bdd))
    }
  }
  func testOperation<A,B>(op: (Rational,Rational) -> A, dop: (Double,Double) -> B, isEq: (A,B) -> Bool) {
    for _ in 0..<n {
      let (a,b) = (Rational.rand,Rational.rand)
      XCTAssert(a.isSimplest)
      XCTAssert(b.isSimplest)
      if closeEnough(a,b.double) { continue }
      XCTAssert(isEq(op(a,b), dop(a.double, b.double)), String(a) + ", " + String(b))
    }
  }
  func testAddition() {
    testOperation(+, dop: +, isEq: closeEnough)
  }
  func testMultiplication() {
    testOperation(*, dop: *, isEq: closeEnough)
  }
  func testSubtraction() {
    testOperation(-, dop: -, isEq: closeEnough)
  }
  func testDivision() {
    testOperation(/, dop: /, isEq: closeEnough)
  }
  func testCompare() {
    testOperation(<, dop: <, isEq: ==)
  }
  func testEq() {
    testOperation(==, dop: ==, isEq: ==)
  }
  func testCommutivity() {
    for _ in 0..<n {
      let (a,b) = (Rational.rand,Rational.rand)
      XCTAssertEqual(a + b, b + a)
      XCTAssertEqual(a * b, b * a)
    }
  }
  func testReciprocal() {
    for _ in 0..<n {
      let r = Rational.rand
      XCTAssertEqual(r.reciprocal, 1 / r)
    }
  }
  func testAssociativity() {
    for _ in 0..<n {
      let (a,b,c) = (Rational.rand,Rational.rand,Rational.rand)
      XCTAssertEqual((a+b)+c, a+(b+c))
      XCTAssertEqual((a*b)*c, a*(b*c))
    }
  }
  func testStrides() {
    for _ in 0..<n {
      let i = Int(arc4random_uniform(20)) + 1
      let l = Rational(i)
      let s = Int(arc4random_uniform(100)) + 1
      var c = 0
      for _ in Rational(0).stride(to: l, by: (1 /% s)) {
        c += 1
      }
      XCTAssertEqual(c, s*i)
    }
  }
}