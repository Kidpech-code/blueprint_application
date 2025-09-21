import '../entities/auth_entities.dart';
import '../value_objects/auth_value_objects.dart';
import '../../../../core/error_handling.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Result<AuthToken>> login(Email email, Password password);

  /// Register new user
  Future<Result<AuthToken>> register(Email email, Password password, Name name);

  /// Logout current user
  Future<Result<void>> logout();

  /// Get current user profile
  Future<Result<User>> getCurrentUser();

  /// Refresh authentication token
  Future<Result<AuthToken>> refreshToken(String refreshToken);

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get stored authentication token
  Future<AuthToken?> getStoredToken();

  /// Store authentication token
  Future<void> storeToken(AuthToken token);

  /// Clear stored authentication data
  Future<void> clearAuthData();

  /// Reset password
  Future<Result<void>> resetPassword(Email email);

  /// Verify email
  Future<Result<void>> verifyEmail(String verificationCode);

  /// Resend verification email
  Future<Result<void>> resendVerificationEmail();
}
