import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entities.dart';
import '../../../../core/error_handling.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Result<User>> call() async {
    return await repository.getCurrentUser();
  }
}
