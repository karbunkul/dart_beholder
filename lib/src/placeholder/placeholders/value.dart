part of 'placeholders.dart';

/// A placeholder that holds a pre-computed static string value.
///
/// Since the value is known at the time of creation, it does not require caching.
final class ValuePlaceholder extends ContextPlaceholder {
  final String _value;

  /// Creates a [ValuePlaceholder] with the given [name] and static [value].
  const ValuePlaceholder({required super.name, required String value})
    : _value = value,
      super(cacheable: false);

  @override
  FutureOr<String> resolve() => _value;
}
