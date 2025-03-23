part of 'transports.dart';

@immutable
final class RecordTransport extends Transport<RecordEntry> {
  @override
  void handle(RecordEntry log) => BeholderController.instance().record.add(log);

  @override
  Future<RecordEntry> log(RecordEntry record) async => record;
}
