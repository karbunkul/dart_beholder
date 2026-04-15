part of 'transport.dart';

/// A function that formats a [RecordEntry] into the result type [R].
typedef OnLogCallback<R, D extends Object> =
    FutureOr<R> Function(RecordEntry<D> record);

/// A transport that wraps another [Transport] and overrides its [log] behavior.
///
/// This is useful for quickly customizing the format of an existing transport
/// without creating a new class.
final class TransportAdapter<R, D extends Object> extends Transport<R, D> {
  /// The underlying transport to which calls are delegated.
  final Transport<R, D> transport;

  /// The function used to override the default [log] behavior.
  final OnLogCallback<R, D> onLog;

  final bool? _needsInit;

  /// Creates a [TransportAdapter] that wraps [transport] and uses [onLog] for formatting.
  ///
  /// [needsInit] can be explicitly set to override the behavior of the wrapped [transport].
  TransportAdapter({
    required this.transport,
    required this.onLog,
    bool? needsInit,
  }) : _needsInit = needsInit;

  @override
  bool get needsInit => _needsInit ?? transport.needsInit;

  @override
  Future<void> init() {
    super.init();
    return transport.init();
  }

  @override
  Future<void> dispose() {
    super.dispose();
    return transport.dispose();
  }

  @override
  FutureOr<R> log(RecordEntry<D> record) => onLog(record);

  @override
  void handle(R log) => transport.handle(log);
}
