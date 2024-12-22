part of 'transport.dart';

@immutable
final class RecordEntry {
  final LogEntry log;
  final PlaceholderManager placeholder;
  final int level;
  final DateTime time;
  final Iterable<String> tags;

  const RecordEntry({
    required this.log,
    required this.placeholder,
    required this.level,
    required this.time,
    required this.tags,
  });
}
