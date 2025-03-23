part of 'controller.dart';

typedef StackInfo = ({Object data, String message});

@immutable
final class StackInfoController {
  final _items = <StackInfo>[];

  void add(StackInfo info) {
    _items.add(info);
  }

  void clear() {
    _items.clear();
  }

  Iterable<StackInfo> get items => UnmodifiableListView(_items);
}
