import 'package:beholder/beholder.dart';
import 'package:beholder/src/core/log_entry_converter.dart';
import 'package:test/test.dart';

void main() {
  group('RecordEntry.toString()', () {
    test('Without converters, call default converter', () {
      final entry = _makeRecordEntry(log: LogEntry(123));
      expect(entry.toString(), '123');
    });

    test('Set custom LogEntryConverter', () {
      final entry = _makeRecordEntry(
        log: LogEntry(42),
        converters: [
          LogEntryConverter(
            onConvert: (data) => 'Number: $data',
          )
        ],
      );

      expect(entry.toString(), equals('Number: 42'));
    });

    test('Use onMap if not null', () {
      final entry = _makeRecordEntry(
        log: LogEntry(
          'Hello',
          onMap: (data) => 'Mapped: $data',
        ),
      );

      expect(entry.toString(), 'Mapped: Hello');
    });
  });
}

RecordEntry _makeRecordEntry({
  required LogEntry log,
  Iterable<LogEntryConverter> converters = const <LogEntryConverter>[],
  int level = 1,
}) {
  final placeholder = PlaceholderManager(
    placeholders: [],
    beholderType: String,
  );

  return RecordEntry(
    log: log,
    placeholder: placeholder,
    level: level,
    time: DateTime.now(),
    converters: converters,
    tags: [],
  );
}
