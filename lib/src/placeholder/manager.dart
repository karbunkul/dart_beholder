part of 'placeholder.dart';

@immutable
final class PlaceholderManager {
  final Type _beholderType;
  final List<ContextPlaceholder> _placeholders;

  late final _cache = BeholderController.instance().cache(_beholderType);

  PlaceholderManager({
    required List<ContextPlaceholder> placeholders,
    required Type beholderType,
  })  : _placeholders = placeholders,
        _beholderType = beholderType;

  FutureOr<String> _replace(String placeholder) async {
    await Future.delayed(Duration.zero);
    if (_cache.hasCache(key: placeholder)) {
      return _cache.get(key: placeholder)!;
    }

    final placeholderInstance = _placeholders
        .firstWhere((p) => p.name.toLowerCase() == placeholder.toLowerCase());

    final value = await placeholderInstance.resolve();

    if (placeholderInstance.cacheable) {
      _cache.set(key: placeholder, value: value);
    }

    return value;
  }

  Future<String?> resolve(String placeholder) async {
    final newPlaceholder = placeholder.toLowerCase();
    if (!available().contains(newPlaceholder)) {
      return null;
    }

    return _replace(newPlaceholder);
  }

  FutureOr<String> template(String template) async {
    final pattern = RegExp(r'\{[a-zA-Z\_]+\}');
    final replaces = <String, String>{};

    for (final match in pattern.allMatches(template)) {
      final source = match.group(0)!;
      final placeholder = source.substring(1, source.length - 1);
      final value = await _replace(placeholder);
      replaces.putIfAbsent(source, () => value);
    }

    var result = template;
    for (final entry in replaces.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  List<String> available() {
    return _placeholders
        .map((e) => e.name.toLowerCase())
        .toList(growable: false);
  }
}
