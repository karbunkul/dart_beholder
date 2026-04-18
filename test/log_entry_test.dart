import 'package:beholder/beholder.dart';
import 'package:beholder/src/core/core.dart';
import 'package:test/test.dart';

void main() {
  group('RecordEntry.toString()', () {
    test('Without converters, call default converter', () {
      final entry = _makeRecordEntry<int>(log: LogEntry<int>(123));
      expect(entry.toString(), '123');
    });

    test('Set custom LogEntryConverter', () {
      final entry = _makeRecordEntry<int>(
        log: LogEntry<int>(42),
        converters: [
          LogEntryConverter<int>(onConvert: (data) => 'Number: $data'),
        ],
      );

      expect(entry.toString(), equals('Number: 42'));
    });

    test('Use specific converter from multiple options', () {
      final entry = _makeRecordEntry<int>(
        log: LogEntry<int>(10),
        converters: [
          LogEntryConverter<String>(onConvert: (data) => 'String: $data'),
          LogEntryConverter<int>(onConvert: (data) => 'Int: $data'),
        ],
      );

      expect(entry.toString(), 'Int: 10');
    });
  });
}

class _FakeCache implements CacheController {
  @override
  String? get({required String key}) => null;
  @override
  bool has({required String key}) => false;
  @override
  void remove({required String key}) {}
  @override
  void resetAll() {}
  @override
  void set({required String key, required String value}) {}
}

RecordEntry<T> _makeRecordEntry<T extends Object>({
  required LogEntry<T> log,
  Iterable<LogEntryConverter> converters = const [],
  int level = 1,
}) {
  final placeholder = PlaceholderManager(placeholders: [])
    ..attach(_FakeCache());

  final converter = converters.firstWhere(
    (e) => e.hasMatch(log.data),
    orElse: () => LogEntryConverter(onConvert: (v) => v.toString()),
  );

  return RecordEntry<T>(
    log: log,
    placeholder: placeholder,
    level: level,
    time: DateTime.now(),
    tags: const [],
    converter: converter,
  );
}
