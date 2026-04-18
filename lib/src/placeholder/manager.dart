part of 'placeholder.dart';

final class PlaceholderManager {
  final List<ContextPlaceholder> _placeholders;
  CacheController? _cache;

  PlaceholderManager({required List<ContextPlaceholder> placeholders})
    : _placeholders = placeholders;

  void attach(CacheController cache) => _cache = cache;

  FutureOr<String> _replace(String placeholder) async {
    await Future.delayed(Duration.zero);
    final cache = _cache;
    if (cache != null && cache.has(key: placeholder)) {
      return cache.get(key: placeholder)!;
    }

    final placeholderInstance = _placeholders.firstWhere(
      (p) => p.name.toLowerCase() == placeholder.toLowerCase(),
    );

    final value = await placeholderInstance.resolve();

    if (placeholderInstance.cacheable) {
      _cache?.set(key: placeholder, value: value ?? '');
    }

    return value ?? '';
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

  /// Returns a list of all available placeholder names.
  List<String> available() {
    return _placeholders.map((e) => e.name).toList(growable: false);
  }

  /// Returns a map of all available placeholders and their descriptions.
  Map<String, String> describe() {
    return {for (final p in _placeholders) p.name: p.description};
  }

  /// Prints all available placeholders and their descriptions to the console.
  void help() {
    if (_placeholders.isEmpty) return;

    // ignore: avoid_print
    print('\nAvailable Placeholders:');
    for (final p in _placeholders) {
      final name = p.name.padRight(24);
      final status = p.cacheable ? 'on ' : 'off';
      final cacheable = 'cacheable is $status';
      // ignore: avoid_print
      print('  $name ($cacheable) - ${p.description}');
    }
    // ignore: avoid_print
    print('');
  }
}
