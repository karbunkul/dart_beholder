/// A flexible, instance-based logging library for Dart and Flutter.
///
/// Beholder provides a powerful pipeline for structured logging with
/// asynchronous lifecycle management, customizable transports, and
/// dynamic placeholder resolution.
library beholder;

export 'src/transport/transport.dart';
export 'src/placeholder/placeholder.dart';
export 'src/core/core.dart' hide RecordController, CacheController;
