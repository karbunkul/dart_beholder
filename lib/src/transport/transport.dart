import 'dart:async';
import 'package:meta/meta.dart';
import 'package:beholder/beholder.dart';

import '../core/core.dart';

part 'transport_adapter.dart';

/// The base class for all log transports (e.g., Console, File, Network).
///
/// [R] is the type of the formatted log record (usually [String] or [Map]).
/// [D] is the type of the data being logged.
abstract class Transport<R, D extends Object> {
  /// Whether this transport requires asynchronous initialization.
  ///
  /// If true, the [Beholder] instance will wait for [init] to complete
  /// before allowing logs to be processed.
  bool get needsInit => false;

  /// Initializes the transport.
  ///
  /// Override this to set up resources like file handles or network connections.
  @mustCallSuper
  Future<void> init() async {}

  /// Disposes of the transport and releases its resources.
  @mustCallSuper
  Future<void> dispose() async {}

  /// Processes the [record] and returns a formatted result of type [R].
  ///
  /// This is the first step of the transport pipeline, usually involving
  /// placeholder resolution.
  FutureOr<R> log(RecordEntry<D> record);

  /// Handles the formatted [log] result (e.g., printing to console or sending to server).
  ///
  /// This is the final step of the transport pipeline.
  void handle(R log);
}
