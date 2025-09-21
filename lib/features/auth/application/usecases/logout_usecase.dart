import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error_handling.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.logout();
  }
}
