import 'dart:async';
import 'package:beholder/src/transport/transport.dart';
import 'package:meta/meta.dart';

import '../filter/filter.dart';

part 'cache.dart';
part 'record.dart';

@immutable
@internal
class BeholderController {
  static final _cache = <Type, _CacheController>{};
  static final _filterState = <Type, FilterState>{};
  static final _recordController = RecordController();

  factory BeholderController.instance() => BeholderController._internal();

  BeholderController._internal();

  @internal
  // ignore: library_private_types_in_public_api
  _CacheController cache(Type type) {
    if (!_cache.keys.contains(type)) {
      _cache.putIfAbsent(type, () => _CacheController());
    }

    return _cache[type]!;
  }

  RecordController get record => _recordController;

  @internal
  FilterState filterState({required Type type, FilterState? state}) {
    if (!_filterState.keys.contains(type)) {
      _filterState.putIfAbsent(type, () => state ?? FilterState(filters: []));
    }

    return _filterState[type]!;
  }
}
