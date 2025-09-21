import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entities.dart';
import '../../../../core/error_handling.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Result<AuthToken>> call(String refreshToken) async {
    return await repository.refreshToken(refreshToken);
  }
}
