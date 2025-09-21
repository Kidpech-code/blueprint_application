import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/core/redirect_resolver.dart';

void main() {
  group('resolveRedirect', () {
    test('uses widgetRedirect when valid', () {
      final res = resolveRedirect(widgetRedirect: '/dashboard', lastFromHistory: '/profile/1', currentUserId: '1');
      expect(res, '/dashboard');
    });

    test('decodes and uses encoded widgetRedirect', () {
      final encoded = Uri.encodeComponent('/blog/2024/01/01/hello');
      final res = resolveRedirect(widgetRedirect: encoded, lastFromHistory: '/profile/1', currentUserId: '1');
      expect(res, '/blog/2024/01/01/hello');
    });

    test('rejects full URL (open redirect)', () {
      final res = resolveRedirect(widgetRedirect: 'https://evil.com', lastFromHistory: '/profile/1', currentUserId: '1');
      expect(res, '/profile/1');
    });

    test('rejects auth paths and uses history', () {
      final res = resolveRedirect(widgetRedirect: '/auth/login', lastFromHistory: '/blog', currentUserId: '1');
      expect(res, '/blog');
    });

    test('uses history when no widgetRedirect', () {
      final res = resolveRedirect(widgetRedirect: null, lastFromHistory: '/blog', currentUserId: '1');
      expect(res, '/blog');
    });

    test('falls back to profile when no widgetRedirect or history', () {
      final res = resolveRedirect(widgetRedirect: null, lastFromHistory: null, currentUserId: '42');
      expect(res, '/profile/42');
    });

    test('falls back to root when nothing else', () {
      final res = resolveRedirect(widgetRedirect: null, lastFromHistory: null, currentUserId: null);
      expect(res, '/');
    });
  });
}
