part of 'transport.dart';

@immutable
final class RecordEntry<T extends Object> {
  final LogEntry<T> log;
  final PlaceholderManager placeholder;
  final int level;
  final DateTime time;
  final Iterable<String> tags;
  final Iterable<LogEntryConverter> _converters;

  const RecordEntry({
    required this.log,
    required this.placeholder,
    required this.level,
    required this.time,
    required this.tags,
    Iterable<LogEntryConverter>? converters,
  }) : _converters = converters ?? const [];

  @override
  String toString() {
    if (log.onMap != null) {
      return log.onMap!.call(log.data);
    }

    final converter = _converters.firstWhere((e) {
      return e.hasMatch(log.data);
    }, orElse: () {
      return LogEntryConverter<T>(onConvert: (e) => e.toString());
    });

    return converter.cast().onConvert(log.data);
  }
}
