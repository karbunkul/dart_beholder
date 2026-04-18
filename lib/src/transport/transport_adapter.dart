part of 'transport.dart';

/// A function that formats a [RecordEntry] into the result type [R].
typedef OnLogCallback<R, D extends Object> =
    FutureOr<R> Function(RecordEntry<D> record);

/// A transport adapter that adds filtering and transformation capabilities to an existing [Transport].
///
/// Use this to wrap a basic transport and apply:
/// * **Type filtering**: Allow or ignore specific data types.
/// * **Tag filtering**: Filter records based on their string tag representations.
/// * **Custom formatting**: Override the default log output using the [onLog] callback.
final class TransportAdapter<R, D extends Object> extends Transport<R, D> {
  /// The underlying transport to which calls are delegated.
  final Transport<R, D> transport;

  /// The function used to override the default [log] behavior.
  final OnLogCallback<R, D> onLog;

  /// A set of data types that this transport should ignore.
  final Set<Type> _ignoredTypes;

  /// A set of data types that this transport should exclusively allow.
  ///
  /// If not empty, only these types will be processed.
  final Set<Type> _allowedTypes;

  /// A set of tags that this transport should exclusively allow.
  final Set<String> _allowedTags;

  /// A set of tags that this transport should ignore.
  final Set<String> _ignoredTags;

  final bool? _needsInit;

  /// Creates a [TransportAdapter] that wraps [transport] and uses [onLog] for formatting.
  ///
  /// * [ignoredTypes]: Records with these data types will be skipped.
  /// * [allowedTypes]: If not empty, only records with these data types will be processed.
  /// * [allowedTags]: If not empty, only records containing at least one of these tags (as strings) will be processed.
  /// * [ignoredTags]: Records containing any of these tags (as strings) will be skipped.
  /// * [needsInit]: Explicitly override the [needsInit] flag of the underlying transport.
  TransportAdapter({
    required this.transport,
    required this.onLog,
    Iterable<Type>? ignoredTypes,
    Iterable<Type>? allowedTypes,
    Iterable<String>? allowedTags,
    Iterable<String>? ignoredTags,
    bool? needsInit,
  }) : _needsInit = needsInit,
       _ignoredTypes = (ignoredTypes ?? []).toSet(),
       _allowedTypes = (allowedTypes ?? []).toSet(),
       _allowedTags = (allowedTags ?? []).toSet(),
       _ignoredTags = (ignoredTags ?? []).toSet(),
       assert(
         !(ignoredTypes?.isNotEmpty == true &&
             allowedTypes?.isNotEmpty == true),
         'You cannot provide both ignoredTypes and allowedTypes. Choose one.',
       ),
       assert(
         !(ignoredTags?.isNotEmpty == true && allowedTags?.isNotEmpty == true),
         'You cannot provide both ignoredTags and allowedTags. Choose one.',
       );

  @override
  bool shouldLog(RecordEntry<D> record) {
    final dataType = record.log.data.runtimeType;

    // Type filtering
    if (_allowedTypes.isNotEmpty) {
      if (!_allowedTypes.contains(dataType)) return false;
    } else if (_ignoredTypes.contains(dataType)) {
      return false;
    }

    // Tag filtering
    if (_allowedTags.isNotEmpty) {
      if (!record.tags.any((t) => _allowedTags.contains(t))) return false;
    } else if (_ignoredTags.isNotEmpty) {
      if (record.tags.any((t) => _ignoredTags.contains(t))) return false;
    }

    return transport.shouldLog(record);
  }

  @override
  Future<void> init() async {
    await super.init();
    await transport.init();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    await transport.dispose();
  }

  @override
  FutureOr<R> log(RecordEntry<D> record) => onLog(record);

  @override
  void handle(R log) => transport.handle(log);
}
