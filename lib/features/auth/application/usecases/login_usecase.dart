import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/value_objects/auth_value_objects.dart';
import '../../../../core/error_handling.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<AuthToken>> call(
    String emailString,
    String passwordString,
  ) async {
    try {
      // Create value objects with validation
      final email = Email.create(emailString);
      final password = Password.create(passwordString);

      // Call repository
      return await repository.login(email, password);
    } on ArgumentError catch (e) {
      return Failure(ValidationError(e.message));
    } catch (e) {
      return Failure(UnknownError('Login failed: $e'));
    }
  }
}
