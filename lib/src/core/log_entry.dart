part of 'core.dart';

/// Represents a single unit of data to be logged.
///
/// [D] is the type of the data (e.g., [String], [Map], or a custom object).
@immutable
class LogEntry<D extends Object> {
  final String? message;

  /// The actual data or message to be logged.
  final D data;

  /// Optional error object associated with this log entry.
  final Object? error;

  /// Optional stack trace associated with this log entry.
  final StackTrace? stackTrace;

  /// Creates a [LogEntry] with the given [data] and optional error context.
  const LogEntry(this.data, {this.message, this.error, this.stackTrace});
}
