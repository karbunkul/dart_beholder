part of 'controller.dart';

@immutable
final class RecordController {
  final _controller = StreamController<RecordEntry>.broadcast();

  void add(RecordEntry entry) => _controller.add(entry);

  Stream<RecordEntry> get stream => _controller.stream;
}
