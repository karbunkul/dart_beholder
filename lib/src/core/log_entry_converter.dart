import 'package:beholder/beholder.dart';
import 'package:meta/meta.dart';

class LogEntryConverter<T extends Object> {
  final OnMapCallback<T> onConvert;

  const LogEntryConverter({required this.onConvert});

  bool hasMatch(Object value) {
    return value is T;
  }

  @internal
  LogEntryConverter<R> cast<R extends Object>() {
    return LogEntryConverter<R>(
      onConvert: (value) => onConvert(value as T),
    );
  }
}
