part of 'placeholder.dart';

abstract base class ContextPlaceholder {
  final String name;
  final bool cacheable;

  const ContextPlaceholder({required this.name, this.cacheable = false});

  FutureOr<String?> resolve();
}
