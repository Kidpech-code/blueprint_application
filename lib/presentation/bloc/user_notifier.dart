import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user.dart';

final getUserUseCaseProvider = Provider<GetUser>((ref) {
  throw UnimplementedError(); // Replace with DI
});

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return null; // initial state
  }

  Future<void> fetchUser(String id) async {
    state = const AsyncLoading();
    try {
      final getUser = ref.read(getUserUseCaseProvider);
      final user = await getUser(id);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
