// RUN: %clang_cc1 -analyze -std=c++11 -analyzer-checker=alpha.clone.CloneChecker -verify %s

// This tests if we search for clones in functions.

void log();

int max(int a, int b) { // expected-warning{{Detected code clone.}}
  log();
  if (a > b)
    return a;
  return b;
}

int maxClone(int x, int y) { // expected-note{{Related code clone is here.}}
  log();
  if (x > y)
    return x;
  return y;
}

// Functions below are not clones and should not be reported.

// The next two functions test that statement classes are still respected when
// checking for clones in expressions. This will show that the statement
// specific data of all base classes is collected, and not just the data of the
// first base class.
int testBaseClass(int a, int b) { // no-warning
  log();
  if (a > b)
    return true ? a : b;
  return b;
}
int testBaseClass2(int a, int b) { // no-warning
  log();
  if (a > b)
    return __builtin_choose_expr(true, a, b);
  return b;
}


int min1(int a, int b) { // no-warning
  log();
  if (a < b)
    return a;
  return b;
}

int foo(int a, int b) { // no-warning
  return a + b;
}
