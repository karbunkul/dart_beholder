part of 'placeholders.dart';

final class SourceFilePlaceholder extends ContextPlaceholder {
  final int depth;
  final StackTrace stackTrace;

  SourceFilePlaceholder({
    required this.depth,
    required this.stackTrace,
  }) : super(name: 'source_file', cacheable: false);

  @override
  FutureOr<String> resolve() {
    final splitStackTrace = stackTrace.toString().split('\n');

    if (depth > splitStackTrace.length) {
      throw RangeError('Invalid depth');
    }

    final source = splitStackTrace.elementAt(depth);
    final pattern = RegExp(r'file\:.[^\)]+');
    final matched = pattern.firstMatch(source);
    if (matched?.start != -1) {
      return source
          .substring(matched!.start, matched.end)
          .replaceFirst(RegExp(r':\d+$'), '');
    }

    return '';
  }
}
