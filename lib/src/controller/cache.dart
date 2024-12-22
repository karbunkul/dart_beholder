part of 'controller.dart';

@immutable
abstract class CacheController {
  void remove({required String key});
  void resetAll();
}

@immutable
final class _CacheController implements CacheController {
  final Map<String, String> _cache = {};

  @internal
  bool hasCache({required String key}) {
    return _cache.keys.contains(key);
  }

  @internal
  String? get({required String key}) {
    print('hit $key');
    return _cache[key];
  }

  @internal
  void set({required String key, required String value}) {
    _cache[key] = value;
  }

  @override
  void remove({required String key}) {
    _cache.remove(key);
  }

  @override
  void resetAll() {
    _cache.clear();
  }
}
