part of 'transports.dart';

final class FileTransport extends Transport<RecordEntry> {
  final String filename;

  const FileTransport({
    required this.filename,
  });

  @override
  Future<void> handle(log) async {
    final file = File(filename);
    final message = await log.placeholder.template(
      '[{log_level_name} {log_tags}][{log_name}: {log_date_time}]'
      '\n{source_file}'
      '\n${log.log.data}\n\n',
    );
    file.writeAsString(message, mode: FileMode.append);
  }

  @override
  Future<RecordEntry> log(entry) async => entry;
}
