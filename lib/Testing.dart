import 'package:flutter_test/flutter_test.dart';

int add(int a, int b) {
  return a + b;
}

void main() {
  test('Test addition function', () {
    expect(add(2, 3), 5); // Expect the result to be 5 when adding 2 and 3.
    expect(add(-1, 1), 0); // Expect the result to be 0 when adding -1 and 1.
  });
}
