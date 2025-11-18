import 'dart:math';

import 'package:auto_rula/auto_rula.dart';
import 'package:auto_rula/src/map_ext.dart';
import 'package:vector_math/vector_math.dart';

Matrix3 _yRotationMatrixFor(Vector3 leftHip, Vector3 rightHip) {
  final angle = 0 - atan2(leftHip.z - rightHip.z, leftHip.x - rightHip.x);
  return Matrix3.rotationY(angle);
}

Matrix3 _zRotationMatrixFor(Vector3 leftHip, Vector3 rightHip) {
  final angle = -atan2(leftHip.y - rightHip.y, leftHip.x - rightHip.x);
  return Matrix3.rotationZ(angle);
}

extension on Pose {
  /// Maps the positions in a [Pose] by applying [map] to each.
  Pose mapPositions(Vector3 Function(Vector3) map) => Pose(
    landmarks.mapValues(
      (_, landmark) => Landmark(map(landmark.position), landmark.confidence),
    ),
  );

  /// Gets the offset from the origin to the [Pose]s mid-hip point.
  Vector3 get midHipOffset => this[KeyPoints.midPelvis].position;

  /// Translates a [Pose] by a given [translation] vector.
  Pose translate(Vector3 translation) {
    return mapPositions((pos) => pos - translation);
  }

  /// Rotates the points in a [Pose] using the given [rotation] matrix.
  Pose rotate(Matrix3 rotation) {
    return mapPositions(rotation.transform);
  }

  /// Translate the [Pose] such that the mid-hip point is at the origin.
  Pose centerHip() {
    final translation = midHipOffset;
    return translate(translation);
  }

  /// Rotates the given [Pose] such that it's hip line is in the XY plane.
  Pose alignHipWithXYPlane() {
    final leftHip = this[KeyPoints.leftHip].position;
    final rightHip = this[KeyPoints.rightHip].position;

    final yRotation = _yRotationMatrixFor(leftHip, rightHip);

    return rotate(yRotation);
  }

  /// Rotates the given [Pose] such that it's hip line is in the XZ plane.
  Pose alignHipWithXZPlane() {
    final leftHip = this[KeyPoints.leftHip].position;
    final rightHip = this[KeyPoints.rightHip].position;

    final zRotation = _zRotationMatrixFor(leftHip, rightHip);

    return rotate(zRotation);
  }

  /// Uniformly scales the given [Pose] such that the hip line is one unit long.
  /// You can also apply additional scaling to the other axes using the [yMult]
  /// and [zMult] parameters.
  Pose normalizeScale(double yMult, double zMult) {
    final hipLength = 2 * this[KeyPoints.leftHip].position.x.abs();
    final scalar = 1 / hipLength;
    return mapPositions(
      (pos) => Vector3(
        pos.x * scalar,
        pos.y * scalar * yMult,
        pos.z * scalar * zMult,
      ),
    );
  }
}

/// A [Pose] which was normalized for easier processing.
///
/// It has the following properties:
///
///  - it's mid-hip point at the origin
///  - it's hip line is aligned with the x-axis
///  - it is scaled such that the hip line is one unit long
extension type NormalizedPose(Pose pose) implements Pose {
  /// Normalizes the given [pose].
  factory NormalizedPose.normalize(Pose pose) => NormalizedPose(
    pose
        // We first want to make sure, that the mid-hip point is at the
        // origin.
        .centerHip()
        // Next we align the hip-line with the x-axis by rotating the pose
        // accordingly.
        // Rotations must be handled separately, as the angle calculation is
        // affected by each transformation (angle estimation cannot be
        // multiplicative)
        .alignHipWithXYPlane()
        .alignHipWithXZPlane()
        // Finally we normalize the pose scale. The axis multipliers here were
        // determined through experimentation.
        .normalizeScale(4, 2),
  );
}
