part of 'core.dart';

/// A callback that converts a log entry value of type [T] to another format.
typedef LogEntryMapper<T extends Object> = Object Function(T value);

/// A converter used to transform specific data types in log entries.
///
/// Transports use this to handle custom objects that need special formatting
/// or processing before being logged.
final class LogEntryConverter<T extends Object> {
  /// The mapper function that performs the conversion.
  final LogEntryMapper<T> onConvert;

  /// Creates a [LogEntryConverter] with the given [onConvert] callback.
  const LogEntryConverter({required this.onConvert});

  /// Returns true if this converter can handle the provided [value].
  bool hasMatch(Object value) => value is T;

  /// Internal method to cast this converter to a different target type.
  ///
  /// This is used for type-safe propagation of converters within the pipeline.
  @internal
  LogEntryConverter<R> cast<R extends Object>() {
    return LogEntryConverter<R>(onConvert: (value) => onConvert(value as T));
  }
}
