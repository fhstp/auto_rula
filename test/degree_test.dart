import 'package:auto_rula/auto_rula.dart';
import 'package:parameterized_test/parameterized_test.dart';
import 'package:test/test.dart';

void main() {
  group('Create degree from normalized angle', () {
    parameterizedTest('should not work for < -180', [-1000.0, -360.5, -181.0], (
      double input,
    ) {
      expect(() => Degree(input), throwsA(isA<AssertionError>()));
    });

    parameterizedTest('should not work for >= 180', [180.0, 360.3, 1000.0], (
      double input,
    ) {
      expect(() => Degree(input), throwsA(isA<AssertionError>()));
    });

    parameterizedTest(
      'should work for [-180, -180[',
      [-180.0, -10.0, 100.6, 179.0],
      (double input) {
        Degree(input);
      },
    );
  });

  parameterizedTest(
    'Angle normalization should give correct outputs',
    [
      [360.0, 0.0],
      [170.0, 170.0],
      [400.0, 40.0],
      [190.0, -170.0],
    ],
    (double input, double expected) {
      final actual = Degree.normalize(input);
      expect(actual.value, equals(expected));
    },
  );

  group('Degree clamping', () {
    test('should clamp min', () {
      const input = Degree(10);
      final actual = input.clamp(20, 100);
      expect(actual.value, equals(20));
    });

    test('should clamp max', () {
      const input = Degree(10);
      final actual = input.clamp(-20, -10);
      expect(actual.value, equals(-10));
    });

    test('should not inputs in range', () {
      const input = Degree(10);
      final actual = input.clamp(-20, 20);
      expect(actual.value, equals(10));
    });
  });
}
