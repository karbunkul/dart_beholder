part of 'core.dart';

@immutable
abstract base class BeholderOptions<T extends Object> {
  List<LogLevel> get levels;
  int get logLevel;

  Transport? get fallbackTransport => null;

  List<ContextPlaceholder> get placeholders => [];

  String mapTagToString(T value) => value.toString();

  @internal
  Iterable<Transport> transportsByLevel(int level) {
    try {
      final logLevel = levels.singleWhere((l) => l.level == level);
      return logLevel.transports;
    } on StateError {
      if (fallbackTransport != null) {
        return [fallbackTransport!];
      } else {
        return [];
      }
    }
  }
}
