part of 'transports.dart';

/// A callback type for printing log messages.
typedef OnPrintCallback = void Function(Object? message);

/// A simple transport that prints logs to the system console.
///
/// By default, it uses [print], but can be configured to use any sync/async function.
final class ConsoleTransport<T extends Object> extends Transport<String, T> {
  /// The function used to print the log message.
  final OnPrintCallback onPrint;

  /// Creates a [ConsoleTransport].
  ConsoleTransport({this.onPrint = print});

  @override
  bool get needsInit => false;

  @override
  FutureOr<String> log(RecordEntry<T> record) {
    return record.description;
  }

  @override
  void handle(String log) {
    onPrint(log);
  }
}
