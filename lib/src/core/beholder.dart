part of 'core.dart';

@immutable
abstract base class Beholder<T extends Object> {
  final String name;
  final BeholderOptions<T> _options;

  Beholder({
    required this.name,
    required BeholderOptions<T> settings,
  }) : _options = settings;

  final _stackInfo = StackInfoController();

  CacheController get cache {
    return BeholderController.instance().cache(runtimeType);
  }

  FilterBuilder<T> get filters {
    return FilterBuilder<T>(onFilter: _onFilterChanged);
  }

  Stream<RecordEntry> get record => BeholderController.instance().record.stream;

  void stackInfo({required String message, required Object info}) {
    _stackInfo.add((data: info, message: message));
  }

  void dispose() => BeholderController.instance().record.close();

  Never rethrowWithStackInfo(Object error, StackTrace stackTrace) {
    final items = <String>[];
    for (final stackInfo in _stackInfo.items) {
      items.add('  - ${stackInfo.message} ${stackInfo.data}');
    }

    final newStack = 'Logger ($name) stack info:\n'
        '${items.join('\n')}'
        '\nStackTrace:\n'
        '${stackTrace.toString()}';
    Error.throwWithStackTrace(error, StackTrace.fromString(newStack));
  }

  @protected
  void log({
    required LogEntry entry,
    required int level,
    List<T>? tags = const [],
    List<ContextPlaceholder>? placeholders,
  }) {
    final transports = _options.transportsByLevel(level);

    if (transports.isNotEmpty && !_checkLog(level: level, tags: tags ?? [])) {
      return;
    }

    final newTags = (tags ?? []).map((e) {
      return _options.mapTagToString(e);
    }).toList(growable: false);

    final logTime = DateTime.now();
    final placeholder = PlaceholderManager(
      beholderType: runtimeType,
      placeholders: [
        ...(placeholders ?? []),
        ..._options.placeholders,
        LazyPlaceholder(name: 'log_name', value: () => name),
        LazyPlaceholder(name: 'log_level', value: () => level.toString()),
        LazyPlaceholder(
          name: 'log_level_name',
          value: () {
            final logLevel =
                _options.levels.firstWhere((e) => e.level == level);

            return logLevel.name.toUpperCase();
          },
        ),
        LazyPlaceholder(name: 'log_tags', value: () => newTags.toString()),
        LazyPlaceholder(
          name: 'log_date_time',
          value: () => logTime.toIso8601String(),
        ),
        LazyPlaceholder(
          name: 'log_date_time_utc',
          value: () => logTime.toUtc().toIso8601String(),
        )
      ],
    );
    final logTags = (tags ?? []).map((e) => _options.mapTagToString(e));

    final record = RecordEntry(
      log: entry,
      placeholder: placeholder,
      level: level,
      time: logTime,
      tags: logTags,
    );

    for (final transport in transports) {
      unawaited(transport.log(record).then(transport.handle));
    }
  }

  bool _checkLog({
    required int level,
    List<T> tags = const [],
  }) {
    const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');

    if (isReleaseMode) {
      return level <= _options.logLevel;
    }

    final state = BeholderController.instance().filterState(type: T);
    if (state.filters.isEmpty) {
      return true;
    }

    final filterTags = state.filters
        .whereType<TagFilter>()
        .map((e) => e.value)
        .toList(growable: false);

    if (filterTags.isNotEmpty) {
      filterTags.sort();
      tags.sort();

      if (filterTags.join() != tags.join()) {
        return false;
      }
    }

    final filterNames = state.filters
        .whereType<LoggerFilter>()
        .map((e) => e.value)
        .toList(growable: false);

    if (filterNames.isNotEmpty && !filterNames.contains(name)) {
      return false;
    }

    final filterLevels = state.filters
        .whereType<LevelFilter>()
        .map((e) => e.value)
        .toList(growable: false);

    if (!filterLevels.contains(level)) {
      return false;
    }

    return true;
  }

  void resetCache({String? placeholder}) {}

  _onFilterChanged(FilterState state) {
    BeholderController.instance().filterState(type: T, state: state);
  }
}
