import 'package:go_router/go_router.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';

class AuthRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) {
        final redirectTo = state.uri.queryParameters['redirect'];
        return LoginView(redirectTo: redirectTo);
      },
    ),
    GoRoute(path: '/auth/register', builder: (context, state) => const RegisterView()),
  ];
}
