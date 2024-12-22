part of 'core.dart';

@immutable
final class LogLevel {
  final int level;
  final String name;
  final List<Transport> transports;

  const LogLevel({
    required this.level,
    required this.name,
    required this.transports,
  });
}
