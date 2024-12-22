part of 'placeholders.dart';

typedef OnPlaceholderCallback = String Function();

base class LazyPlaceholder extends ContextPlaceholder {
  final OnPlaceholderCallback value;

  LazyPlaceholder({
    required super.name,
    required this.value,
    super.cacheable,
  });

  @override
  FutureOr<String> resolve() => value();
}
