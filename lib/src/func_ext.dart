/// Extensions for value piping.
extension PipeExt<T> on T {
  /// Pipe this value through the given function [f], allowing for
  /// in-place method chaining.
  U pipe<U>(U Function(T) f) {
    return f(this);
  }
}
