import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entities.dart';
import '../../../../core/error_handling.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Result<Profile>> call(String userId) async {
    return await repository.getProfile(userId);
  }
}
