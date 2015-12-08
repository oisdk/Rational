![travis](https://travis-ci.org/oisdk/Rational.svg)

# Rational

A basic implementation of fractions in Swift.

The only exposed initialiser for the struct automatically simplifies
before storing. The user cannot manually adjust the numerator and
denominator. This ensures that the fraction is always stored in its 
simplest form:

```swift
String(6 /% 8) == 3/4
```

The numerator is stored as the maximum-sized signed integer type, 
and the denominator is stored as the maximum-sized unsigned integer
type.
