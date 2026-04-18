import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

final class _TestData {}

final class _MockTransport extends Transport<String, Object> {
  int handleCallCount = 0;
  String? lastLogged;

  @override
  Future<String> log(RecordEntry<Object> record) async => record.description;

  @override
  void handle(String log) {
    handleCallCount++;
    lastLogged = log;
  }
}

void main() {
  group('TransportAdapter', () {
    late _MockTransport mock;

    setUp(() {
      mock = _MockTransport();
    });

    test('should ignore specified types', () async {
      final adapter = TransportAdapter<String, Object>(
        transport: mock,
        ignoredTypes: {_TestData},
        onLog: (record) => record.description,
      );

      final record = RecordEntry<Object>(
        log: LogEntry(_TestData()),
        placeholder: PlaceholderManager(placeholders: []),
        level: 100,
        time: DateTime.now(),
        tags: const [],
        converter: LogEntryConverter(onConvert: (v) => v.toString()),
      );

      // shouldLog should be false for _TestData
      expect(adapter.shouldLog(record), isFalse);
    });

    test('should allow non-ignored types', () async {
      final adapter = TransportAdapter<String, Object>(
        transport: mock,
        ignoredTypes: {_TestData},
        onLog: (record) => record.description,
      );

      final record = RecordEntry<Object>(
        log: LogEntry('Some string data'),
        placeholder: PlaceholderManager(placeholders: []),
        level: 100,
        time: DateTime.now(),
        tags: const [],
        converter: LogEntryConverter(onConvert: (v) => v.toString()),
      );

      expect(adapter.shouldLog(record), isTrue);
    });

    test('should respect underlying transport shouldLog', () async {
      // Create a scenario where the inner transport would return false
      // (though our mock returns true by default)
      final adapter = TransportAdapter<String, Object>(
        transport: mock,
        onLog: (record) => record.description,
      );

      final record = RecordEntry<Object>(
        log: LogEntry('data'),
        placeholder: PlaceholderManager(placeholders: []),
        level: 100,
        time: DateTime.now(),
        tags: const [],
        converter: LogEntryConverter(onConvert: (v) => v.toString()),
      );

      expect(adapter.shouldLog(record), isTrue);
    });
  });
}
