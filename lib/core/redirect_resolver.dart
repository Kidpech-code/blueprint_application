// Utility for resolving safe redirect paths after login

/// Resolve a safe redirect path after login.
/// Priority:
/// 1. widgetRedirect (decoded and validated)
/// 2. RouteHistory.last (validated)
/// 3. fallback to profile path if userId provided, else '/'
String resolveRedirect({String? widgetRedirect, String? lastFromHistory, String? currentUserId}) {
  String? candidate = widgetRedirect;

  String? tryValidate(String? path) {
    if (path == null || path.isEmpty) return null;
    // Prevent full URLs
    if (path.contains('://')) return null;
    // Must be a path
    if (!path.startsWith('/')) return null;
    // Exclude auth pages
    if (path.startsWith('/auth')) return null;
    return path;
  }

  // decode if needed
  if (candidate != null) {
    try {
      candidate = Uri.decodeComponent(candidate);
    } catch (_) {}
    final validated = tryValidate(candidate);
    if (validated != null) return validated;
  }

  // try last from history
  final validatedHistory = tryValidate(lastFromHistory);
  if (validatedHistory != null) return validatedHistory;

  // fallback to profile or root
  if (currentUserId != null && currentUserId.isNotEmpty) {
    return '/profile/$currentUserId';
  }
  return '/';
}
