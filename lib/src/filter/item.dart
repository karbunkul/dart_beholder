part of 'filter.dart';

@immutable
@internal
abstract base class FilterItem<T> {
  final T value;

  const FilterItem({required this.value});

  bool hasMatch(T other) => value == other;
}

@immutable
final class TagFilter<T extends Object> extends FilterItem<T> {
  const TagFilter({required super.value});
}

@immutable
final class LevelFilter extends FilterItem<int> {
  const LevelFilter({required super.value});
}

@immutable
final class LoggerFilter extends FilterItem<String> {
  const LoggerFilter({required super.value});
}
