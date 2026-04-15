import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

// Вспомогательный класс для тестов, так как BeholderOptions абстрактный
base class TestOptions extends BeholderOptions<String> {
  final List<LogLevel> _levels;
  final int _logLevel;
  final Transport<Object, Object>? _fallbackTransport;

  TestOptions(
    this._levels, {
    int logLevel = 100,
    Transport<Object, Object>? fallbackTransport,
  }) : _logLevel = logLevel,
       _fallbackTransport = fallbackTransport;

  @override
  List<LogLevel> get levels => _levels;

  @override
  int get logLevel => _logLevel;

  @override
  Transport<Object, Object>? get fallbackTransport => _fallbackTransport;
}

// Фейковый логгер для тестирования защищенных методов Beholder
base class TestBeholder extends Beholder<String> {
  TestBeholder({required super.name, required super.settings});

  void testLog(String message) {
    log(entry: LogEntry(message), level: 0);
  }
}

class MockTransport extends Transport<String, String> {
  final bool _needsInit;
  bool initCalled = false;
  bool disposeCalled = false;
  bool handleCalled = false;

  MockTransport({bool needsInit = false}) : _needsInit = needsInit;

  @override
  bool get needsInit => _needsInit;

  @override
  Future<void> init() async {
    await super.init();
    initCalled = true;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    disposeCalled = true;
  }

  @override
  Future<String> log(RecordEntry<String> record) async {
    return record.log.data;
  }

  @override
  void handle(String log) {
    handleCalled = true;
  }
}

void main() {
  group('Transport Lifecycle via Beholder', () {
    test('Beholder should call init() and dispose() on transports', () async {
      final transport = MockTransport(needsInit: true);
      final beholder = TestBeholder(
        name: 'test',
        settings: TestOptions([
          LogLevel(level: 0, name: 'info', transports: [transport]),
        ]),
      );

      expect(transport.initCalled, isFalse);

      await beholder.init();
      expect(transport.initCalled, isTrue);

      await beholder.dispose();
      expect(transport.disposeCalled, isTrue);
    });

    test(
      'Beholder should throw StateError if transport needs init but Beholder is not initialized',
      () {
        final transport = MockTransport(needsInit: true);
        final beholder = TestBeholder(
          name: 'test',
          settings: TestOptions([
            LogLevel(level: 0, name: 'info', transports: [transport]),
          ]),
        );

        expect(
          () => beholder.testLog('hello'),
          throwsA(anyOf(isA<StateError>(), isA<AssertionError>())),
        );
      },
    );

    test('Beholder should NOT throw if no transports need init', () {
      final transport = MockTransport(needsInit: false);
      final beholder = TestBeholder(
        name: 'test',
        settings: TestOptions([
          LogLevel(level: 0, name: 'info', transports: [transport]),
        ]),
      );

      expect(() => beholder.testLog('hello'), returnsNormally);
    });
  });

  group('TransportAdapter', () {
    test('should correctly propagate and override needsInit', () {
      final base = MockTransport(needsInit: false);

      final adapter1 = TransportAdapter<String, String>(
        transport: base,
        onLog: (e) => e.log.data,
      );
      expect(adapter1.needsInit, isFalse);

      final adapter2 = TransportAdapter<String, String>(
        transport: base,
        onLog: (e) => e.log.data,
        needsInit: true,
      );
      expect(adapter2.needsInit, isTrue);
    });

    test('should delegate init/dispose to wrapped transport', () async {
      final base = MockTransport(needsInit: true);
      final adapter = TransportAdapter<String, String>(
        transport: base,
        onLog: (e) => e.log.data,
      );

      await adapter.init();
      expect(base.initCalled, isTrue);

      await adapter.dispose();
      expect(base.disposeCalled, isTrue);
    });
  });
}
