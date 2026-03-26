import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/value_objects/auth_value_objects.dart';
import '../../../../core/error_handling.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Result<AuthToken>> call(
    String emailString,
    String passwordString,
    String nameString,
  ) async {
    try {
      // Create value objects with validation
      final email = Email.create(emailString);
      final password = Password.create(passwordString);
      final name = Name.create(nameString);

      // Call repository
      return await repository.register(email, password, name);
    } on ArgumentError catch (e) {
      return Failure(ValidationError(e.message));
    } catch (e) {
      return Failure(UnknownError('Registration failed: $e'));
    }
  }
}
