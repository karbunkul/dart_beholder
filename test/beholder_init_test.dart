import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

class MockTransport extends Transport<String, String> {
  final bool _needsInit;
  MockTransport({bool needsInit = false}) : _needsInit = needsInit;

  @override
  bool get needsInit => _needsInit;

  @override
  Future<String> log(RecordEntry<String> record) async => record.log.data;

  @override
  void handle(String log) {}
}

base class TestOptions extends BeholderOptions<String> {
  final List<LogLevel> _levels;
  TestOptions(this._levels);

  @override
  List<LogLevel> get levels => _levels;
  @override
  int get logLevel => 100;
}

base class TestBeholder extends Beholder<String> {
  TestBeholder({required super.name, required super.settings});

  void testLog(String message) {
    log(entry: LogEntry(message), level: 1);
  }
}

void main() {
  group('Beholder Initialization Guard', () {
    test(
      'should throw if any transport needs init and logger is NOT initialized',
      () {
        final transport = MockTransport(needsInit: true);
        final beholder = TestBeholder(
          name: 'test',
          settings: TestOptions([
            LogLevel(level: 1, name: 'debug', transports: [transport]),
          ]),
        );

        expect(
          () => beholder.testLog('hello'),
          throwsA(anyOf(isA<StateError>(), isA<AssertionError>())),
        );
      },
    );

    test('should NOT throw if no transport needs init', () {
      final transport = MockTransport(needsInit: false);
      final beholder = TestBeholder(
        name: 'test',
        settings: TestOptions([
          LogLevel(level: 1, name: 'debug', transports: [transport]),
        ]),
      );

      expect(() => beholder.testLog('hello'), returnsNormally);
    });

    test('should NOT throw if initialized', () async {
      final transport = MockTransport(needsInit: true);
      final beholder = TestBeholder(
        name: 'test',
        settings: TestOptions([
          LogLevel(level: 1, name: 'debug', transports: [transport]),
        ]),
      );

      await beholder.init();
      expect(() => beholder.testLog('hello'), returnsNormally);
    });
  });
}
