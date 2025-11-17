import 'package:meta/meta.dart';

/// An angle in degrees in the range [-180; 180[.
@immutable
class Degree {
  /// Makes a degree from a angle which is already in the valid [-180, 180[
  /// range.
  ///
  /// Throws an [AssertionError] if the given value is not in the correct
  /// range.
  const Degree(this.value)
    : assert(value >= -180, 'Angle must be at least -180°'),
      assert(value < 180, 'Angle must be less than 180°');

  /// Makes a new [Degree] object by normalizing an arbitrary [angle].
  factory Degree.normalize(double angle) {
    angle %= 360;
    if (angle >= 0 && angle < 180) return Degree(angle);
    return Degree(angle - 360);
  }

  /// The wrapped value. Guaranteed to be in the correct value range.
  final double value;

  /// 0°
  static const Degree zero = Degree(0);

  @override
  String toString() {
    return '$value°';
  }

  /// Creates a new [Degree] by clamping this one between [min] and [max].
  ///
  /// [min] must be larger than or equal to -180 and smaller than [max].
  /// [max] must be smaller than 180.
  Degree clamp(double min, double max) {
    assert(min < max, 'Max must be larger than min');
    final angle = value.clamp(min, max);
    return Degree(angle);
  }
}
