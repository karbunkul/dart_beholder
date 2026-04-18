part of 'core.dart';

/// The base class for creating loggers in the Beholder system.
///
/// [Beholder] is instance-based and manages the lifecycle of its [Transport]s.
/// It provides a pipeline for processing [LogEntry]s, applying filters,
/// and resolving placeholders.
abstract base class Beholder<T extends Object> {
  /// The name of this logger instance, used in placeholders like `{log_name}`.
  final String name;
  final BeholderOptions<T> _options;
  final List<Transport> _transports;
  final Map<int, String> _levelNames;
  final bool _anyTransportNeedsInit;
  bool _isInitialized = false;

  /// Creates a [Beholder] instance with the given [name] and [settings].
  Beholder({required this.name, required BeholderOptions<T> settings})
    : _options = settings,
      _cache = _CacheController(),
      _recordController = RecordController<Object>(),
      _filterState = FilterState(filters: []),
      _transports = _extractUniqueTransports(settings),
      _levelNames = {
        for (final l in settings.levels) l.level: l.name.toUpperCase(),
      },
      _anyTransportNeedsInit =
          settings.levels.any((l) => l.transports.any((t) => t.needsInit)) ||
          (settings.fallbackTransport?.needsInit ?? false) {
    for (final converter in settings.converters) {
      _converterCache[converter.type] = converter;
    }
  }

  static List<Transport> _extractUniqueTransports(BeholderOptions settings) {
    final transports = <Transport>{};
    for (final level in settings.levels) {
      transports.addAll(level.transports);
    }
    if (settings.fallbackTransport != null) {
      transports.add(settings.fallbackTransport!);
    }
    return List.unmodifiable(transports);
  }

  final _CacheController _cache;
  final Map<Type, LogEntryConverter> _converterCache = {};
  final RecordController<Object> _recordController;
  FilterState _filterState;

  /// Provides access to the internal [CacheController] for managing placeholder cache.
  CacheController get cache => _cache;

  /// Returns a [FilterBuilder] to dynamically configure log filtering for this instance.
  FilterBuilder<T> get filters {
    return FilterBuilder<T>(onFilter: _onFilterChanged);
  }

  /// A stream of [RecordEntry]s processed by this logger.
  /// Useful for global monitoring or secondary processing.
  Stream<RecordEntry<Object>> get record => _recordController.stream;

  /// Initializes the logger and all its [Transport]s.
  ///
  /// This must be called and awaited if any transport has [Transport.needsInit] set to true.
  /// If initialization fails for any transport, [_isInitialized] will remain false.
  @mustCallSuper
  Future<void> init() async {
    if (_isInitialized) {
      final error = StateError('Beholder ($name) is already initialized.');
      assert(false, error.message);
      _options.onErrorHandler(error, StackTrace.current);
      return;
    }

    for (final transport in _transports) {
      try {
        await transport.init();
      } catch (e, stackTrace) {
        _options.onErrorHandler(e, stackTrace);
        // If any transport fails to initialize, we don't mark the whole thing as initialized
        // and we might want to dispose already initialized ones to stay consistent.
        // For now, we'll just return and let the user handle it via onErrorHandler.
        return;
      }
    }
    _isInitialized = true;
  }

  /// Disposes of the logger and closes all its [Transport]s.
  ///
  /// Once disposed, the logger cannot be used again.
  @mustCallSuper
  Future<void> dispose() async {
    if (!_isInitialized) {
      final error = StateError(
        'Beholder ($name) is not initialized or already disposed.',
      );
      assert(false, error.message);
      _options.onErrorHandler(error, StackTrace.current);
      return;
    }
    _isInitialized = false;

    for (final transport in _transports) {
      try {
        await transport.dispose();
      } catch (e, stackTrace) {
        _options.onErrorHandler(e, stackTrace);
      }
    }
    await _recordController.close();
  }

  /// Logs a [LogEntry] with the specified [level].
  ///
  /// [tags] can be used for filtering.
  /// [placeholders] allow providing additional context for this specific log call.
  ///
  /// Throws [StateError] if the logger requires initialization but [init] wasn't called.
  @protected
  void log<D extends Object>({
    required LogEntry<D> entry,
    required int level,
    List<T>? tags = const [],
    List<ContextPlaceholder>? placeholders,
  }) {
    if (_anyTransportNeedsInit && !_isInitialized) {
      final message =
          'Beholder ($name) must be initialized before use because some of its transports require initialization. '
          'Ensure that you called [await logger.init()].';
      throw StateError(message);
    }

    final transports = _options.transportsByLevel(level);

    if (transports.isNotEmpty && !_checkLog(level: level, tags: tags ?? [])) {
      return;
    }

    final logTags = (tags ?? [])
        .map((e) => _options.mapTagToString(e))
        .toList(growable: false);

    final logTime = DateTime.now();

    late final RecordEntry<D> record;

    final placeholder = PlaceholderManager(
      placeholders: [
        ...(placeholders ?? []),
        ..._options.placeholders,
        LazyPlaceholder(name: 'logName', loader: () => name, cacheable: true),
        LazyPlaceholder(
          name: 'logLevel',
          loader: () => level.toString(),
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logLevelName',
          loader: () => _levelNames[level],
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logTags',
          loader: () => logTags.toString(),
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logDateTime',
          loader: () => logTime.toIso8601String(),
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logDateTimeUtc',
          loader: () => logTime.toUtc().toIso8601String(),
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logData',
          loader: () => record.description,
          cacheable: true,
        ),
        LazyPlaceholder(
          name: 'logMessage',
          loader: () => record.log.message,
          cacheable: true,
        ),
      ],
    )..attach(_cache);

    final dataType = entry.data.runtimeType;
    final converter = _converterCache[dataType] ??= _options.converters
        .firstWhere(
          (e) => e.hasMatch(entry.data),
          orElse: () => LogEntryConverter(onConvert: (v) => v.toString()),
        );

    record = RecordEntry<D>(
      log: entry,
      placeholder: placeholder,
      level: level,
      time: logTime,
      tags: logTags,
      converter: converter,
    );

    _recordController.add(record);

    for (final transport in transports) {
      if (!transport.shouldLog(record)) {
        continue;
      }

      unawaited(
        Future.value(transport.log(record))
            .then(transport.handle)
            .catchError((e, st) => _options.onErrorHandler(e, st)),
      );
    }
  }

  bool _checkLog({required int level, List<T> tags = const []}) {
    // 1. Global level check (priority #1)
    if (level < _options.logLevel) {
      return false;
    }

    // 2. Dynamic filters (always active)
    final state = _filterState;
    if (state.filters.isEmpty) {
      return true;
    }

    final filterTags = state.filters
        .whereType<TagFilter>()
        .map((e) => e.value)
        .toSet();

    if (filterTags.isNotEmpty) {
      final tagsSet = tags.toSet();
      // Record must have all tags from filters
      if (!filterTags.every(tagsSet.contains)) {
        return false;
      }
    }

    final filterNames = state.filters.whereType<LoggerFilter>().map(
      (e) => name == e.value,
    );

    if (filterNames.isNotEmpty && !filterNames.any((e) => e)) {
      return false;
    }

    final filterLevels = state.filters
        .whereType<LevelFilter>()
        .map((e) => e.value)
        .toList(growable: false);

    if (filterLevels.isNotEmpty && !filterLevels.contains(level)) {
      return false;
    }

    return true;
  }

  /// Resets the cache for a specific [placeholder] or all placeholders if null.
  void resetCache({String? placeholder}) {
    if (placeholder != null) {
      _cache.remove(key: placeholder);
    } else {
      _cache.resetAll();
    }
  }

  _onFilterChanged(FilterState state) {
    _filterState = state;
  }
}
