part of 'transport.dart';

typedef OnLogOverrideCallback<T> = Future<T> Function(RecordEntry entry);

@immutable
final class TransportAdapter<T extends Object> extends Transport<T> {
  final Transport transport;
  final OnLogOverrideCallback<T> onLog;

  const TransportAdapter({
    required this.transport,
    required this.onLog,
  });

  @override
  void handle(T log) {
    transport.handle(log);
  }

  @override
  Future<T> log(RecordEntry record) {
    return onLog(record);
  }
}
