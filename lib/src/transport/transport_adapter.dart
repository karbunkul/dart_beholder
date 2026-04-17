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

  /// A set of data types that this transport should ignore.
  final Set<Type> ignoredTypes;

  /// A set of data types that this transport should exclusively allow.
  ///
  /// If not empty, only these types will be processed.
  final Set<Type> allowedTypes;

  final bool? _needsInit;

  /// Creates a [TransportAdapter] that wraps [transport] and uses [onLog] for formatting.
  ///
  /// [ignoredTypes] allows specifying types that should not be processed.
  /// [allowedTypes] allows specifying the only types that should be processed.
  /// [needsInit] can be explicitly set to override the behavior of the wrapped [transport].
  TransportAdapter({
    required this.transport,
    required this.onLog,
    this.ignoredTypes = const {},
    this.allowedTypes = const {},
    bool? needsInit,
  }) : _needsInit = needsInit,
       assert(
         !(ignoredTypes.isNotEmpty && allowedTypes.isNotEmpty),
         'You cannot provide both ignoredTypes and allowedTypes. Choose one.',
       );

  @override
  bool shouldLog(RecordEntry<D> record) {
    final dataType = record.log.data.runtimeType;

    if (allowedTypes.isNotEmpty) {
      return allowedTypes.contains(dataType) && transport.shouldLog(record);
    }

    if (ignoredTypes.contains(dataType)) return false;

    return transport.shouldLog(record);
  }

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
