part of 'transports.dart';

/// A transport that writes log records to a file.
///
/// This transport requires initialization to open the file stream.
final class FileTransport extends Transport<String, Object> {
  /// The path to the file where logs will be written.
  final String filename;

  IOSink? _sink;

  /// Creates a [FileTransport] with the given [filename].
  FileTransport({required this.filename});

  @override
  bool get needsInit => true;

  @override
  Future<void> init() async {
    await super.init();
    final file = File(filename);

    // Ensure that the directory exists before opening the file
    final directory = file.parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _sink = file.openWrite(mode: FileMode.append);
  }

  @override
  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    await super.dispose();
  }

  @override
  void handle(String log) {
    _sink?.write(log);
  }

  @override
  Future<String> log(RecordEntry<Object> record) async {
    return record.placeholder.template(
      '[{log_level_name} {log_tags}][{log_name}: {log_date_time}]'
      '\n{source_file}'
      '\n${record.log.data}\n\n',
    );
  }
}
