part of 'placeholder.dart';

abstract base class ContextPlaceholder {
  final String name;
  final String description;
  final bool cacheable;

  const ContextPlaceholder({
    required this.name,
    required this.description,
    this.cacheable = false,
  });

  FutureOr<String?> resolve();
}
