import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// Utility extensions for [IMap]s
extension MapExt<Key, Value> on IMap<Key, Value> {
  /// Creates a new [IMap] by keeping all keys and creating values using
  /// [f].
  IMap<Key, Mapped> mapValues<Mapped>(
    Mapped Function(Key key, Value value) f,
  ) => map((key, value) => MapEntry(key, f(key, value)));
}
