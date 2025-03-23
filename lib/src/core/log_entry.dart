part of 'core.dart';

typedef OnMapCallback<T extends Object> = String Function(T data);

@immutable
final class LogEntry<T extends Object> {
  final T data;
  final String? description;
  final OnMapCallback<T>? onMap;

  const LogEntry(
    this.data, {
    this.description,
    this.onMap,
  });
}
