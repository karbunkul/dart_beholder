import 'dart:async';
import 'package:beholder/beholder.dart';

/// 1. Define your log tags (optional, but recommended for type-safety).
enum AppTag {
  ui('ui'),
  network('network'),
  auth('auth');

  final String name;
  const AppTag(this.name);
}

/// A sample technical data class that we might want to ignore in some transports.
final class Heartbeat {
  final DateTime time = DateTime.now();
  @override
  String toString() => 'Heartbeat at $time';
}

/// 2. Define your logger options.
final class MyOptions extends BeholderOptions<AppTag> {
  @override
  int get logLevel => 100; // Only log levels >= 100

  @override
  String mapTagToString(AppTag tag) => tag.name;

  @override
  List<LogEntryConverter> get converters => [
    LogEntryConverter<AppTag>(onConvert: (value) => value?.name ?? 'unknown'),
  ];

  @override
  List<LogLevel> get levels => [
    LogLevel(
      level: 100,
      name: 'info',
      transports: [
        // Use TransportAdapter to ignore Heartbeat messages in console
        TransportAdapter(
          transport: ConsoleTransport(),
          // ignoredTypes: {Heartbeat},
          allowedTypes: {Heartbeat},
          allowedTags: {AppTag.ui.name},
          onLog: (record) {
            print(record.placeholder.available());

            return record.description;
          },
        ),
      ],
    ),
    LogLevel(
      level: 200,
      name: 'error',
      transports: [ConsoleTransport(onPrint: (msg) => print('🚨 ERROR: $msg'))],
    ),
  ];

  @override
  List<ContextPlaceholder> get placeholders => [
    // Custom global placeholder
    ValuePlaceholder(name: 'version', value: '0.9.7'),
  ];

  @override
  void onErrorHandler(Object error, StackTrace stackTrace) {
    print('Beholder caught an error: $error');
  }
}

/// 3. Create your logger class.
final class MyLogger extends Beholder<AppTag> {
  MyLogger(String name) : super(name: name, settings: MyOptions());

  void info(Object data, {String? message, List<AppTag>? tags}) {
    log(
      level: 100,
      entry: LogEntry(data, message: message),
      tags: tags,
    );
  }

  void error(
    String message, {
    Object? error,
    StackTrace? st,
    List<AppTag>? tags,
  }) {
    log(
      level: 200,
      entry: LogEntry(message, error: error, stackTrace: st),
      tags: tags,
    );
  }
}

Future<void> main() async {
  final logger = MyLogger('App');

  // 4. MUST initialize the logger before use if any transport needs it.
  // In v0.9.7, it's a good practice to always await init().
  await logger.init();

  // 5. Listen to all records (e.g., for analytics)
  logger.record.listen((record) {
    // record.description resolves data via converters or toString()
    // print('Stream monitor: ${record.description}');
  });

  // 6. Use filters dynamically
  logger.filters
    ..tag(.ui)
    ..apply();

  // This will NOT be printed because it doesn't have the AppTag.ui tag
  logger.info('This is a network message', tags: [AppTag.network]);

  // This WILL be printed
  logger.info('UI initialized!', tags: [AppTag.ui]);
  logger.info(AppTag.auth, tags: [AppTag.ui]);

  // This will NOT be printed because Heartbeat is in ignoredTypes
  logger.info(Heartbeat(), tags: [AppTag.ui]);

  // Logging an error with source file info
  logger.error(
    'Something went wrong',
    error: Exception('Auth failed'),
    tags: [AppTag.ui, AppTag.auth],
  );

  // 7. Cleanup
  await logger.dispose();

  print('Example finished.');
}
