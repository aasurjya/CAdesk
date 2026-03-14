/// Simple in-memory cache with TTL for feature flags.
class FlagCache {
  FlagCache({Duration ttl = const Duration(minutes: 5)}) : _ttl = ttl;

  final Duration _ttl;
  final Map<String, bool> _flags = {};
  DateTime? _lastFetched;

  bool get isStale {
    final fetched = _lastFetched;
    if (fetched == null) return true;
    return DateTime.now().difference(fetched) > _ttl;
  }

  Map<String, bool> get flags => Map.unmodifiable(_flags);

  bool isEnabled(String flagName) => _flags[flagName] ?? false;

  void update(Map<String, bool> flags) {
    _flags
      ..clear()
      ..addAll(flags);
    _lastFetched = DateTime.now();
  }

  void invalidate() => _lastFetched = null;
}
