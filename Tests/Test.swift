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

let n = 1000

class RationalTests: XCTestCase {
  func testDoubleEquiv() {
    for _ in 0..<n {
      let (a,b) = (IntMax.rand,IntMax.rand)
      let (c,d) = (UIntMax.rand,UIntMax.rand)
      let ac = a /% c
      let bd = b /% d
      let acd = Double(a) / Double(c)
      let bdd = Double(b) / Double(d)
      XCTAssert(closeEnough(ac, acd))
      XCTAssert(closeEnough(bd, bdd))
    }
  }
  func testOperation<A,B>(op: (Rational,Rational) -> A, dop: (Double,Double) -> B, isEq: (A,B) -> Bool) {
    for _ in 0..<n {
      let (a,b) = (Rational.rand,Rational.rand)
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
}