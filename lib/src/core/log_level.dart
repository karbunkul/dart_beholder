part of 'core.dart';

/// Defines a logging level and its associated transports.
@immutable
final class LogLevel {
  /// The numeric value of the level (e.g., 10, 50, 100).
  final int level;

  /// The human-readable name of the level (e.g., 'info', 'debug', 'error').
  final String name;

  /// The list of [Transport]s that will process logs for this specific level.
  final List<Transport<Object, Object>> transports;

  /// Creates a [LogLevel] definition.
  const LogLevel({
    required this.level,
    required this.name,
    required this.transports,
  });
}
