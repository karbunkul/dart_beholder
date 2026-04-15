import 'package:beholder/beholder.dart';
import 'package:beholder/src/core/core.dart';
import 'package:test/test.dart';

base class TestOptions extends BeholderOptions<String> {
  @override
  List<LogLevel> get levels => [];
  @override
  int get logLevel => 100;
}

base class TestBeholder extends Beholder<String> {
  TestBeholder() : super(name: 'test', settings: TestOptions());
}

void main() {
  group('CacheController', () {
    test('should store and retrieve values', () {
      final beholder = TestBeholder();
      final cache = beholder.cache;

      cache.set(key: 'foo', value: 'bar');
      expect(cache.has(key: 'foo'), isTrue);
      expect(cache.get(key: 'foo'), equals('bar'));
    });

    test('should return null for non-existent keys', () {
      final beholder = TestBeholder();
      final cache = beholder.cache;

      expect(cache.has(key: 'missing'), isFalse);
      expect(cache.get(key: 'missing'), isNull);
    });

    test('should remove specific keys', () {
      final beholder = TestBeholder();
      final cache = beholder.cache;

      cache.set(key: 'key1', value: 'val1');
      cache.set(key: 'key2', value: 'val2');

      beholder.resetCache(placeholder: 'key1');

      expect(cache.has(key: 'key1'), isFalse);
      expect(cache.has(key: 'key2'), isTrue);
    });

    test('should reset all keys', () {
      final beholder = TestBeholder();
      final cache = beholder.cache;

      cache.set(key: 'key1', value: 'val1');
      cache.set(key: 'key2', value: 'val2');

      beholder.resetCache();

      expect(cache.has(key: 'key1'), isFalse);
      expect(cache.has(key: 'key2'), isFalse);
    });
  });
}
