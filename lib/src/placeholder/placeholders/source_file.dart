part of 'placeholders.dart';

final class SourceFilePlaceholder extends ContextPlaceholder {
  final int depth;
  final StackTrace stackTrace;

  SourceFilePlaceholder({required this.depth, required this.stackTrace})
    : super(
        name: 'source_file',
        cacheable: false,
        description: 'Extract source file from stack trace via depth parameter',
      );

  @override
  FutureOr<String> resolve() {
    final splitStackTrace = stackTrace.toString().split('\n');

    if (depth >= splitStackTrace.length) {
      throw RangeError(
        'Invalid depth: $depth (total frames: ${splitStackTrace.length})',
      );
    }

    final source = splitStackTrace.elementAt(depth);

    // 1. Look for pattern in parentheses (Standard Dart/Flutter)
    // #0      Method (package:app/main.dart:10:5) -> group 1
    // 2. Look for pattern without parentheses (Web/Release)
    // #0      package:app/main.dart 10:5 -> group 2 and 3
    final pattern = RegExp(
      r'\(([^)]+)\)|(?:#\d+\s+)?([^\s]+)\s+(\d+:\d+)|([^\s]+:\d+:\d+)',
    );

    final match = pattern.firstMatch(source);
    if (match != null) {
      // Found in parentheses
      if (match.group(1) != null) return match.group(1)!;

      // Found format "path line:col" (Web)
      if (match.group(2) != null && match.group(3) != null) {
        return '${match.group(2)}:${match.group(3)}';
      }

      // Found format "path:line:col" directly
      if (match.group(4) != null) return match.group(4)!;
    }

    return '';
  }
}
