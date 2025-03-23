import 'dart:async';

import 'package:meta/meta.dart';

import '../core/core.dart';
import '../core/log_entry_converter.dart';
import '../placeholder/placeholder.dart';

part 'adapter.dart';
part 'record_entry.dart';

@immutable
abstract base class Transport<T extends Object> {
  const Transport();

  Future<T> log(RecordEntry<T> record);
  void handle(T log);
}
