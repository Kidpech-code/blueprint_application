import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/value_objects/auth_value_objects.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_models.dart';
import '../../../../core/error_handling.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<AuthToken>> login(Email email, Password password) async {
    try {
      final request = LoginRequest(
        email: email.value,
        password: password.value,
      );

      final response = await remoteDataSource.login(request);
      final token = response.token.toEntity();

      // Store token and user locally
      await localDataSource.storeToken(response.token);
      await localDataSource.storeUser(response.user);

      return Success(token);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Login failed: $e'));
    }
  }

  @override
  Future<Result<AuthToken>> register(
    Email email,
    Password password,
    Name name,
  ) async {
    try {
      final request = RegisterRequest(
        email: email.value,
        password: password.value,
        name: name.value,
      );

      final response = await remoteDataSource.register(request);
      final token = response.token.toEntity();

      // Store token and user locally
      await localDataSource.storeToken(response.token);
      await localDataSource.storeUser(response.user);

      return Success(token);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Registration failed: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final token = await localDataSource.getStoredToken();

      if (token != null) {
        try {
          await remoteDataSource.logout(token.accessToken);
        } catch (e) {
          // Even if remote logout fails, we still clear local data
        }
      }

      await localDataSource.clearAuthData();
      return const Success(null);
    } catch (e) {
      return Failure(UnknownError('Logout failed: $e'));
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getStoredToken();

      if (token == null || token.toEntity().isExpired) {
        return const Failure(
          AuthenticationError('No valid authentication token'),
        );
      }

      // Try to get user from local storage first
      final localUser = await localDataSource.getStoredUser();
      if (localUser != null) {
        return Success(localUser.toEntity());
      }

      // If not available locally, fetch from remote
      final remoteUser = await remoteDataSource.getCurrentUser(
        token.accessToken,
      );
      await localDataSource.storeUser(remoteUser);

      return Success(remoteUser.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get current user: $e'));
    }
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    try {
      final newTokenModel = await remoteDataSource.refreshToken(refreshToken);
      final newToken = newTokenModel.toEntity();

      await localDataSource.storeToken(newTokenModel);

      return Success(newToken);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Token refresh failed: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await localDataSource.getStoredToken();
      return token != null && !token.toEntity().isExpired;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    try {
      final tokenModel = await localDataSource.getStoredToken();
      return tokenModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> storeToken(AuthToken token) async {
    final tokenModel = AuthTokenModel.fromEntity(token);
    await localDataSource.storeToken(tokenModel);
  }

  @override
  Future<void> clearAuthData() async {
    await localDataSource.clearAuthData();
  }

  @override
  Future<Result<void>> resetPassword(Email email) async {
    try {
      await remoteDataSource.resetPassword(email.value);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Password reset failed: $e'));
    }
  }

  @override
  Future<Result<void>> verifyEmail(String verificationCode) async {
    try {
      final token = await localDataSource.getStoredToken();

      if (token == null || token.toEntity().isExpired) {
        return const Failure(
          AuthenticationError('No valid authentication token'),
        );
      }

      await remoteDataSource.verifyEmail(verificationCode, token.accessToken);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Email verification failed: $e'));
    }
  }

  @override
  Future<Result<void>> resendVerificationEmail() async {
    try {
      final token = await localDataSource.getStoredToken();

      if (token == null || token.toEntity().isExpired) {
        return const Failure(
          AuthenticationError('No valid authentication token'),
        );
      }

      await remoteDataSource.resendVerificationEmail(token.accessToken);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to resend verification email: $e'));
    }
  }
}
