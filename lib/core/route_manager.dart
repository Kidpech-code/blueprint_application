import 'package:go_router/go_router.dart';
import 'dependency_injection.dart';
import 'route_history.dart';

// Import feature routes
import '../features/auth/presentation/routes/auth_routes.dart';
import '../features/profile/presentation/routes/profile_routes.dart';
import '../features/blog/presentation/routes/blog_routes.dart';

// Import views for error handling
import '../features/common/presentation/views/not_found_view.dart';
import '../features/common/presentation/views/error_view.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/auth/login',
    errorBuilder: (context, state) => ErrorView(error: state.error?.toString() ?? 'Unknown error occurred'),
    routes: [
      // Home route
      GoRoute(path: '/', builder: (context, state) => const NotFoundView(), redirect: (context, state) => '/auth/login'),

      // Auth Feature Routes
      ...AuthRoutes.routes,

      // Profile Feature Routes
      ...ProfileRoutes.routes,

      // Blog Feature Routes
      ...BlogRoutes.routes,

      // Catch-all route for 404
      GoRoute(path: '/404', builder: (context, state) => const NotFoundView()),
    ],
    redirect: (context, state) {
      // Add global redirect logic here if needed
      // For example, check authentication status
      return null;
    },
    debugLogDiagnostics: true,
  );

  static GoRouter get router => _router;

  // Navigation helper methods
  static void go(String location) {
    // Update route history (will ignore auth paths internally)
    try {
      if (sl.isRegistered<RouteHistory>()) sl<RouteHistory>().update(location);
    } catch (_) {}
    _router.go(location);
  }

  static void push(String location) {
    try {
      if (sl.isRegistered<RouteHistory>()) sl<RouteHistory>().update(location);
    } catch (_) {}
    _router.push(location);
  }

  static void pop() {
    _router.pop();
  }

  static void replace(String location) {
    try {
      if (sl.isRegistered<RouteHistory>()) sl<RouteHistory>().update(location);
    } catch (_) {}
    _router.pushReplacement(location);
  }

  static bool canPop() {
    return _router.canPop();
  }

  // Specific navigation methods for features
  static void goToLogin({String? redirectTo}) {
    final location = redirectTo != null ? '/auth/login?redirect=$redirectTo' : '/auth/login';
    go(location);
  }

  static void goToRegister() {
    go('/auth/register');
  }

  static void goToProfile(String userId, {String? tab}) {
    final location = tab != null ? '/profile/$userId?tab=$tab' : '/profile/$userId';
    go(location);
  }

  static void goToBlogPost({required String year, required String month, required String day, required String slug, bool? preview}) {
    final location = preview == true ? '/blog/$year/$month/$day/$slug?preview=true' : '/blog/$year/$month/$day/$slug';
    go(location);
  }

  static void goToBlogList() {
    go('/blog');
  }

  static void goToEventBooking(String eventId, {String? step, String? coupon}) {
    var location = '/event/$eventId/booking';
    final queryParams = <String, String>{};

    if (step != null) queryParams['step'] = step;
    if (coupon != null) queryParams['coupon'] = coupon;

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      location = '$location?$query';
    }

    go(location);
  }
}
