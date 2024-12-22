part of 'core.dart';

typedef OnMapCallback<T> = String Function(T data);

@immutable
final class LogEntry<T> {
  final T data;
  final String? description;
  final OnMapCallback<T>? onMap;

  const LogEntry(
    this.data, {
    this.description,
    this.onMap,
  });
}
