class RouteHistory {
  String? _lastNonAuthLocation;

  // Whitelist of paths that should not be saved as last location
  final List<String> _excludePrefixes = ['/auth', '/404'];

  void update(String location) {
    if (location.isEmpty) return;
    // Do not store if it's an auth route or other excluded
    for (final p in _excludePrefixes) {
      if (location.startsWith(p)) return;
    }
    _lastNonAuthLocation = location;
  }

  String? get last => _lastNonAuthLocation;

  void clear() => _lastNonAuthLocation = null;
}
