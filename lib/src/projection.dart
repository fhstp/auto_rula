import 'package:auto_rula/auto_rula.dart';
import 'package:auto_rula/src/map_ext.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:vector_math/vector_math.dart';

/// A [Pose] which was projected onto a plane and has become two-dimensional.
///
/// Instead of containing a mapping from key points to [Landmark]s, it maps
/// to [Vector2].
class ProjectedPose {
  /// Create a pose from the given positions.
  ProjectedPose(this.positionsByKeyPoint);

  /// Creates a [ProjectedPose] by projecting the given 3D [pose].
  ///
  /// Each [Landmark] in the [pose] is sent through [projectPoint] in order
  /// to get a 2D position.
  ///
  /// Only [Landmark]s with a confidence >= [minConfidence] are kept.
  factory ProjectedPose.project(
    NormalizedPose pose,
    Vector2 Function(Vector3) projectPoint, {
    required double minConfidence,
  }) => ProjectedPose(
    pose.landmarks
        .where((_, landmark) => landmark.confidence >= minConfidence)
        .mapValues((_, landmark) => projectPoint(landmark.position)),
  );

  /// Creates a [ProjectedPose] by projecting the given 3D [pose] onto the
  /// coronal plane.
  ///
  /// Only [Landmark]s with a confidence >= [minConfidence] are kept.
  factory ProjectedPose.coronal(
    NormalizedPose pose, {
    double minConfidence = 0.9,
  }) => ProjectedPose.project(
    pose,
    (pos3d) => Vector2(pos3d.x, pos3d.y),
    minConfidence: minConfidence,
  );

  /// Creates a [ProjectedPose] by projecting the given 3D [pose] onto the
  /// sagittal plane.
  ///
  /// Only [Landmark]s with a confidence >= [minConfidence] are kept.
  factory ProjectedPose.sagittal(
    NormalizedPose pose, {
    double minConfidence = 0.9,
  }) => ProjectedPose.project(
    pose,
    (pos3d) => Vector2(pos3d.z, pos3d.y),
    minConfidence: minConfidence,
  );

  /// Creates a [ProjectedPose] by projecting the given 3D [pose] onto the
  /// transverse plane.
  ///
  /// Only [Landmark]s with a confidence >= [minConfidence] are kept.
  factory ProjectedPose.transverse(
    NormalizedPose pose, {
    double minConfidence = 0.9,
  }) => ProjectedPose.project(
    pose,
    (pos3d) => Vector2(pos3d.x, pos3d.z),
    minConfidence: minConfidence,
  );

  /// The pose's positions keyed by their [KeyPoints] identifier.
  ///
  /// **Importantly, in comparison to [Pose] and [NormalizedPose],
  /// this map is not required to contain all [KeyPoints].**
  final IMap<KeyPoints, Vector2> positionsByKeyPoint;

  /// Get the position for a specific [KeyPoints].
  Vector2? operator [](KeyPoints point) => positionsByKeyPoint[point];

  /// [Iterable] over all positions in this pose.
  Iterable<Vector2> get positions => positionsByKeyPoint.values;
}
