part of 'core.dart';

/// Interface for managing the placeholder cache.
///
/// Use this to manually clear cached values if the underlying data changes.
abstract interface class CacheController {
  /// Removes a cached value for a specific placeholder [key].
  void remove({required String key});

  /// Clears all cached values.
  void resetAll();

  /// Internal: Checks if a value exists in the cache.
  @internal
  bool has({required String key});

  /// Internal: Retrieves a value from the cache.
  @internal
  String? get({required String key});

  /// Internal: Stores a [value] in the cache for the given [key].
  @internal
  void set({required String key, required String value});
}

/// Private implementation of [CacheController].
final class _CacheController implements CacheController {
  final Map<String, String> _cache = {};

  @override
  bool has({required String key}) => _cache.containsKey(key);

  @override
  String? get({required String key}) => _cache[key];

  @override
  void set({required String key, required String value}) => _cache[key] = value;

  @override
  void remove({required String key}) => _cache.remove(key);

  @override
  void resetAll() => _cache.clear();
}
