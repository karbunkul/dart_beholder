import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

void main() {
  group('SourceFilePlaceholder', () {
    test('should resolve standard Dart stack trace', () async {
      final st = StackTrace.fromString(
        '#0      Logger.trace (package:beholder/example/beholder_example.dart:92:7)\n'
        '#1      main (package:beholder/example/beholder_example.dart:105:10)',
      );

      final placeholder = SourceFilePlaceholder(depth: 0, stackTrace: st);
      final result = await placeholder.resolve();

      expect(
        result,
        equals('package:beholder/example/beholder_example.dart:92:7'),
      );
    });

    test(
      'should resolve location for FilterBuilder.reset with depth 1',
      () async {
        final st = StackTrace.fromString(
          '#0      FilterBuilder.reset (package:beholder/src/filter/builder.dart:45:10)\n'
          '#1      main (package:beholder/example/beholder_example.dart:92:7)',
        );

        final placeholder = SourceFilePlaceholder(depth: 1, stackTrace: st);
        final result = await placeholder.resolve();

        expect(
          result,
          equals('package:beholder/example/beholder_example.dart:92:7'),
        );
      },
    );

    test('should resolve web-style stack trace or shortened paths', () async {
      final st = StackTrace.fromString(
        'main.dart 10:5  main\n'
        'dart:ui         _runMainZoned',
      );

      final placeholder = SourceFilePlaceholder(depth: 0, stackTrace: st);
      final result = await placeholder.resolve();

      expect(result, contains('main.dart:10:5'));
    });

    test('should resolve Flutter release-style stack trace', () async {
      final st = StackTrace.fromString(
        '#0      abs_path/main.dart:10:5\n'
        '#1      package:my_app/main.dart 20:1',
      );

      final placeholder = SourceFilePlaceholder(depth: 1, stackTrace: st);
      final result = await placeholder.resolve();

      expect(result, equals('package:my_app/main.dart:20:1'));
    });

    test('should resolve absolute file path', () async {
      final st = StackTrace.fromString(
        '#0      MyClass.method (file:///Users/user/project/lib/main.dart:10:5)\n'
        '#1      anotherMethod (file:///Users/user/project/lib/main.dart:20:1)',
      );

      final placeholder = SourceFilePlaceholder(depth: 0, stackTrace: st);
      final result = await placeholder.resolve();

      expect(result, equals('file:///Users/user/project/lib/main.dart:10:5'));
    });

    test('should resolve Flutter-style stack trace with raw path', () async {
      final st = StackTrace.fromString(
        '#0      _MyHomePageState._incrementCounter (/Users/karbunkul/Projects/app/lib/main.dart:25:7)\n'
        '#1      _RenderPointerListener.handleEvent (package:flutter/src/rendering/proxy_box.dart:2852:14)',
      );

      final placeholder = SourceFilePlaceholder(depth: 0, stackTrace: st);
      final result = await placeholder.resolve();

      expect(
        result,
        equals('/Users/karbunkul/Projects/app/lib/main.dart:25:7'),
      );
    });

    test('should handle different depth', () async {
      final st = StackTrace.fromString(
        '#0      Frame0 (file:A.dart:1:1)\n'
        '#1      Frame1 (file:B.dart:2:2)',
      );

      final placeholder = SourceFilePlaceholder(depth: 1, stackTrace: st);
      final result = await placeholder.resolve();

      expect(result, equals('file:B.dart:2:2'));
    });

    test('should throw RangeError on invalid depth', () {
      final st = StackTrace.fromString('#0      Frame0 (file:A.dart:1:1)');
      final placeholder = SourceFilePlaceholder(depth: 5, stackTrace: st);

      expect(() => placeholder.resolve(), throwsRangeError);
    });
  });
}
