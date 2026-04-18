part of 'placeholders.dart';

/// A callback that returns a string value for a placeholder.
typedef PlaceholderLoader = String? Function();

/// A placeholder that computes its value lazily when resolved.
///
/// This is useful for dynamic values that might change or are expensive to compute.
final class LazyPlaceholder extends ContextPlaceholder {
  /// The function used to compute the placeholder value.
  final PlaceholderLoader loader;

  /// Creates a [LazyPlaceholder] with the given [name] and [loader].
  LazyPlaceholder({
    required super.name,
    required this.loader,
    super.cacheable = false,
  });

  String? _value;
  bool _resolved = false;

  @override
  FutureOr<String?> resolve() {
    if (!cacheable) {
      return loader();
    }

    if (!_resolved) {
      _value = loader();
      _resolved = true;
    }

    return _value;
  }
}
