import 'package:auto_rula/auto_rula.dart';
import 'package:meta/meta.dart';

Degree _clampRightAngle(Degree x) => x.clamp(-90, 90);

Degree _clampStraightLine(Degree x) => x.clamp(0, 179);

/// A pair of [Degree] used for body parts of which there are two.
typedef DegreePair = (Degree, Degree);

/// Models a [RULA sheet](https://ergo-plus.com/rula-assessment-tool-guide/).
///
/// Each field on this class corresponds to a point on the sheet. The
/// following points are currently not included.
///
///  - Whether the person is leaning on something (1)
///  - Elbow varus-valgus angle (2a)
///  - Wrist ulnar-radial deviation (3a)
///  - Forearm pronation-supination (4)
///
/// We do track point 8 (stable standing), but use our own heuristic, since
/// the Rula sheet does not provide one. See [RulaSheet.legAngleDiff].
///
/// Mostly this object tracks angles of various joints in [Degree]s. For joints
/// of which there is a symmetric pair, such as for the knees or elbows, they
/// are stored as a tuple of [Degree]s or [DegreePair].
@immutable
class RulaSheet {
  /// Creates an instance of the [RulaSheet] class with th given parameters.
  ///
  /// Angles will be clamped into sensible ranges for the relevant joints.
  ///
  /// For example, [RulaSheet.shoulderAbduction] will be clamped to the
  /// [0, 180[ range, while [RulaSheet.neckFlexion] only makes sense as a right
  /// angle in the range [-90, 90]
  RulaSheet({
    required this.shoulderFlexion,
    required DegreePair shoulderAbduction,
    required DegreePair elbowFlexion,
    required this.wristFlexion,
    required Degree neckFlexion,
    required this.neckRotation,
    required Degree neckLateralFlexion,
    required Degree hipFlexion,
    required this.trunkRotation,
    required Degree trunkLateralFlexion,
    required this.legAngleDiff,
  }) : shoulderAbduction = Pair.map(_clampStraightLine)(shoulderAbduction),
       elbowFlexion = Pair.map(_clampStraightLine)(elbowFlexion),
       neckFlexion = _clampRightAngle(neckFlexion),
       neckLateralFlexion = _clampRightAngle(neckLateralFlexion),
       hipFlexion = _clampStraightLine(hipFlexion),
       trunkLateralFlexion = _clampRightAngle(trunkLateralFlexion);

  /// Fills out a [RulaSheet] using the given [angles].
  factory RulaSheet.fromAngles(PoseAngles angles) {
    Degree angleOf(KeyAngles key) {
      final angle = angles[key]!;
      return Degree.normalize(angle);
    }

    Degree angleDiff(KeyAngles a, KeyAngles b) {
      final angleA = angles[a]!;
      final angleB = angles[b]!;
      final diff = (angleA - angleB).abs();
      return Degree.normalize(diff);
    }

    return RulaSheet(
      shoulderFlexion: (
        angleOf(KeyAngles.shoulderFlexionLeft),
        angleOf(KeyAngles.shoulderFlexionRight),
      ),
      shoulderAbduction: (
        angleOf(KeyAngles.shoulderAbductionLeft),
        angleOf(KeyAngles.shoulderAbductionRight),
      ),
      elbowFlexion: (
        angleOf(KeyAngles.elbowFlexionLeft),
        angleOf(KeyAngles.elbowFlexionRight),
      ),
      wristFlexion: (
        angleOf(KeyAngles.wristFlexionLeft),
        angleOf(KeyAngles.wristFlexionRight),
      ),
      neckFlexion: angleOf(KeyAngles.neckFlexion),
      neckRotation: angleOf(KeyAngles.neckTwist),
      neckLateralFlexion: angleOf(KeyAngles.neckSideBend),
      hipFlexion: angleOf(KeyAngles.trunkStoop),
      trunkRotation: angleOf(KeyAngles.trunkTwist),
      trunkLateralFlexion: angleOf(KeyAngles.trunkSideBend),
      legAngleDiff: (
        angleDiff(KeyAngles.kneeFlexionLeft, KeyAngles.legFlexionLeft),
        angleDiff(KeyAngles.kneeFlexionRight, KeyAngles.legFlexionRight),
      ),
    );
  }

  /// The flexion angles of the upper arm.
  ///
  /// 0° is considered pointing straight down along the torso. Negative values
  /// indicate hyperextension, while positive ones indicate flexion.
  ///
  /// Corresponds to point 1.
  final DegreePair shoulderFlexion;

  /// The abduction angles of the upper arm.
  ///
  /// 0° is considered pointing straight down along the torso.
  /// Positive values indicate abduction. Range is [0, 180[.
  ///
  /// Corresponds to point 1a.
  final DegreePair shoulderAbduction;

  /// The flexion angle of the lower arm.
  ///
  /// 0° is considered pointing in parallel with the upper arm.
  /// Positive values indicate flexion. Range is [0, 180[.
  ///
  /// Corresponds to point 2.
  final DegreePair elbowFlexion;

  /// The flexion angle of the wrist.
  ///
  /// 0° indicates a wrist in parallel with the lower arm. Negative values
  /// indicate extension while positive ones indicate flexion.
  ///
  /// Corresponds to point 3.
  final DegreePair wristFlexion;

  /// The flexion angle of the neck.
  ///
  /// 0° indicates a neck in parallel with the torso. Positive values indicate
  /// flexion while negative ones indicate extension. Range is [-90, 90]
  ///
  /// Corresponds to point 6.
  final Degree neckFlexion;

  /// The twisting angle of the neck.
  ///
  /// 0° indicates looking straight ahead. Positive values indicate twisting
  /// left and negative ones right.
  ///
  /// Corresponds to point 6a.
  final Degree neckRotation;

  /// The side-to-side flexion angle of the neck.
  ///
  /// 0° flexion to the left and negative to the right. Range is [-90, 90].
  ///
  /// Corresponds to point 6a.
  final Degree neckLateralFlexion;

  /// The flexion angle of the torso.
  ///
  /// 0° indicates a torso in line with the legs. Positive values indicate
  /// bending forward. Range is [0, 180[.
  ///
  /// Corresponds to point 7.
  final Degree hipFlexion;

  /// The twisting angle of the trunk.
  ///
  /// 0° indicates facing straight ahead. Positive values indicate twisting left
  /// and negative ones right.
  ///
  /// Corresponds to point 7a.
  final Degree trunkRotation;

  /// The side-to-side flexion angle of the trunk.
  ///
  /// 0° indicates being in parallel with the legs. Positive values indicate
  /// bending to the left, while negative ones to the right. Range is
  /// [-90, 90].
  ///
  /// Corresponds to point 7a.
  final Degree trunkLateralFlexion;

  /// The difference between the inner angle of the knee and the angle between
  /// trunk and upper leg.
  ///
  /// We use the difference between these angles to score how 'stably' a person
  /// is standing.
  final DegreePair legAngleDiff;
}
