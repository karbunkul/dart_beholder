part of 'core.dart';

/// Represents a formatted log record that is passed to transports.
///
/// [T] is the type of the data being logged.
@immutable
final class RecordEntry<T extends Object> {
  /// The original log entry containing data, error, and stack trace.
  final LogEntry<T> log;

  /// The placeholder manager used to resolve context values for this record.
  final PlaceholderManager placeholder;

  /// The numeric level of this log record.
  final int level;

  /// The timestamp when the log record was created.
  final DateTime time;

  /// The list of string tags associated with this record.
  final Iterable<String> tags;

  /// A string representation of the log data after processing by converters.
  String get description => toString();

  final LogEntryConverter _converter;

  /// Creates a [RecordEntry] with the given metadata.
  const RecordEntry({
    required this.log,
    required this.placeholder,
    required this.level,
    required this.time,
    required this.tags,
    required LogEntryConverter converter,
  }) : _converter = converter;

  @override
  String toString() {
    return _converter.cast().onConvert(log.data).toString();
  }
}

/// An internal controller that manages the stream of [RecordEntry]s.
@internal
final class RecordController<T extends Object> {
  final _controller = StreamController<RecordEntry<T>>.broadcast();

  /// Adds a new [entry] to the stream.
  void add(RecordEntry<T> entry) {
    if (!_controller.isClosed) {
      _controller.add(entry);
    }
  }

  /// The broadcast stream of record entries.
  Stream<RecordEntry<T>> get stream => _controller.stream;

  /// Closes the underlying stream controller.
  Future<void> close() {
    return _controller.close();
  }
}
