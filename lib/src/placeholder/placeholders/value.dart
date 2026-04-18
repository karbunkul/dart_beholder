part of 'placeholders.dart';

/// A placeholder that holds a pre-computed static string value.
final class ValuePlaceholder extends ContextPlaceholder {
  final String _value;

  /// Creates a [ValuePlaceholder] with the given [name], static [value], and [description].
  const ValuePlaceholder({
    required super.name,
    required super.description,
    required String value,
  }) : _value = value,
       super(cacheable: false);

  @override
  FutureOr<String> resolve() => _value;
}
