import 'package:go_router/go_router.dart';
import '../views/profile_view.dart';

class ProfileRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final tab = state.uri.queryParameters['tab'];
        return ProfileView(userId: userId, tab: tab);
      },
    ),
  ];
}
