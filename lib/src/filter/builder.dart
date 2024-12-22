part of 'filter.dart';

typedef OnFilterCallback = Function(FilterState state);

@immutable
final class FilterBuilder<T extends Object> {
  final OnFilterCallback onFilter;
  final _filters = <FilterItem>[];

  FilterBuilder({required this.onFilter});

  FilterBuilder tag(T tag) {
    _filters.add(TagFilter<T>(value: tag));
    return this;
  }

  FilterBuilder level(int level) {
    _filters.add(LevelFilter(value: level));
    return this;
  }

  FilterBuilder logger(String name) {
    _filters.add(LoggerFilter(value: name));
    return this;
  }

  void apply() {
    if (_filters.isNotEmpty) {
      final sourceFile = SourceFilePlaceholder(
        depth: 1,
        stackTrace: StackTrace.current,
      );
      print('Warning: Filtered logs in ${sourceFile.resolve()}');
    }
    onFilter(FilterState(filters: List.of(_filters)));
    _filters.clear();
  }

  FilterBuilder reset() {
    _filters.clear();
    onFilter(FilterState(filters: []));
    return this;
  }
}
