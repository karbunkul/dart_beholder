part of 'transports.dart';

@immutable
final class RecordTransport extends Transport<RecordEntry> {
  @override
  void handle(log) => BeholderController.instance().record.add(log);

  @override
  Future<RecordEntry> log(entry) async => entry;
}
