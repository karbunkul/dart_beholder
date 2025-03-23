import 'dart:async';

import 'package:beholder/beholder.dart';

enum AppLogTag {
  ui('ui'),
  network('network');

  final String id;

  const AppLogTag(this.id);
}

final class UserPlaceholder extends ContextPlaceholder {
  const UserPlaceholder() : super(name: 'user', cacheable: true);

  @override
  FutureOr<String> resolve() => 'karbunkul';
}

final class ConsoleTransport extends Transport<String> {
  @override
  Future<String> log(entry) async {
    return entry.placeholder.template(
        '[{log_level_name} {log_tags}][{log_name}: {log_date_time}]\n{source_file} {user}'
        '\n${entry.log.data}\n');
  }

  @override
  void handle(String log) => print(log);
}

final class _Settings extends BeholderOptions<AppLogTag> {
  @override
  String mapTagToString(value) => value.id;

  @override
  List<LogLevel> get levels {
    return [
      LogLevel(
        level: 100,
        name: 'trace',
        transports: [
          // ConsoleTransport(),
          // FileTransport(filename: './log-2.txt'),
          RecordTransport(),
          TransportAdapter(
            transport: ConsoleTransport(),
            onLog: (record) async {
              return record.placeholder.template(
                  '[{log_level_name}][{log_name} {log_tags}: {log_date_time}]\n{source_file}');
            },
          ),
        ],
      ),
    ];
  }

  @override
  List<ContextPlaceholder> get placeholders {
    return [UserPlaceholder()];
  }

  @override
  int get logLevel => 100;
}

final class Logger extends Beholder<AppLogTag> {
  Logger(String name) : super(name: name, settings: _Settings());

  void trace(LogEntry entry, {List<AppLogTag>? tags}) {
    log(
      entry: entry,
      level: 100,
      tags: tags,
      placeholders: [
        SourceFilePlaceholder(depth: 1, stackTrace: StackTrace.current),
      ],
    );
  }

  @override
  void stackInfo({required String message, required Object info}) {
    super.stackInfo(message: message, info: info);
    trace(LogEntry(info, description: message));
  }
}

Future<void> main() async {
  const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');
  final logger = Logger('test');

  logger.record.listen((value) {
    print(value.toString());
  });

  logger.filters
    ..level(100)
    // ..tag(AppLogTag.ui)
    ..reset()
    ..apply();

  logger.trace(LogEntry('value $isReleaseMode'), tags: [AppLogTag.network]);
  logger.trace(LogEntry('value 234'), tags: [AppLogTag.ui]);
  logger.stackInfo(message: 'foo', info: 2);
  logger.stackInfo(message: 'bar', info: 4);

  logger.rethrowWithStackInfo(UnimplementedError(), StackTrace.current);
  await Future.delayed(const Duration(milliseconds: 300), logger.dispose);
}
