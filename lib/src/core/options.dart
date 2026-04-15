part of 'core.dart';

/// Configuration options for a [Beholder] instance.
///
/// [T] is the type used for log tags.
abstract base class BeholderOptions<T extends Object> {
  /// The minimum log level that will be processed.
  ///
  /// Records with a level lower than this will be ignored in release mode.
  int get logLevel;

  /// A list of defined [LogLevel]s and their associated transports.
  List<LogLevel> get levels;

  /// An optional transport that will receive ALL log records, regardless of level.
  Transport? get fallbackTransport => null;

  /// A list of global [ContextPlaceholder]s that will be available for all logs.
  List<ContextPlaceholder> get placeholders => const [];

  /// A list of [LogEntryConverter]s to handle custom data types.
  List<LogEntryConverter> get converters => const [];

  /// An optional handler for errors that occur within the logging pipeline.
  ///
  /// This includes errors during transport initialization, disposal, or logging.
  /// By default, it prints the error to the console.
  void onErrorHandler(Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('Beholder Error: $error\n$stackTrace');
  }

  /// Returns a list of [Transport]s that should process records for the given [level].
  ///
  /// By default, it includes transports from the matching [LogLevel] and the [fallbackTransport].
  @protected
  @visibleForTesting
  List<Transport> transportsByLevel(int level) {
    final transports = <Transport>{};

    for (final l in levels) {
      if (l.level == level) {
        transports.addAll(l.transports);
      }
    }

    if (fallbackTransport != null) {
      transports.add(fallbackTransport!);
    }

    return List.unmodifiable(transports);
  }

  /// Maps a tag of type [T] to its [String] representation.
  ///
  /// Defaults to [toString]. Override this for custom tag formatting.
  String mapTagToString(T tag) => tag.toString();
}
