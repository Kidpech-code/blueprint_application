import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:blueprint_application/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:blueprint_application/features/auth/application/usecases/login_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/register_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/logout_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/get_current_user_usecase.dart';
import 'package:blueprint_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';
import 'package:blueprint_application/core/error_handling.dart';

/// **Simple ViewModel Tests**
///
/// ตัวอย่างการทดสอบ Presentation Layer แบบง่ายๆ
/// เน้นการทดสอบ state management และ business logic integration

// Helper function for waiting async operations
Future<void> waitForAsyncOp([int milliseconds = 150]) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

// Simplified Fake Repository for ViewModel Testing
class SimpleAuthRepository implements AuthRepository {
  Result<AuthToken>? _loginResult;
  Result<User>? _getCurrentUserResult;
  bool _shouldSucceed = true;

  void setLoginResult(Result<AuthToken> result) => _loginResult = result;
  void setGetCurrentUserResult(Result<User> result) => _getCurrentUserResult = result;
  void setShouldSucceed(bool value) => _shouldSucceed = value;

  @override
  Future<Result<AuthToken>> login(Email email, Password password) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate network

    if (_loginResult != null) {
      return _loginResult!;
    }

    if (_shouldSucceed) {
      return Success(AuthToken(accessToken: 'test-token', refreshToken: 'test-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1))));
    } else {
      return Failure(AuthenticationError('Login failed'));
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 5));

    if (_getCurrentUserResult != null) {
      return _getCurrentUserResult!;
    }

    if (_shouldSucceed) {
      return Success(User(id: 'test-user', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now()));
    } else {
      return Failure(AuthenticationError('User not found'));
    }
  }

  @override
  Future<Result<AuthToken>> register(Email email, Password password, Name name) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Success(
      AuthToken(accessToken: 'register-token', refreshToken: 'register-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1))),
    );
  }

  @override
  Future<Result<void>> logout() async {
    return const Success(null);
  }

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<AuthToken?> getStoredToken() async => null;

  @override
  Future<void> storeToken(AuthToken token) async {}

  @override
  Future<void> clearAuthData() async {}

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    return Success(AuthToken(accessToken: 'new-token', refreshToken: 'new-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1))));
  }

  @override
  Future<Result<void>> resetPassword(Email email) async => const Success(null);

  @override
  Future<Result<void>> verifyEmail(String verificationCode) async => const Success(null);

  @override
  Future<Result<void>> resendVerificationEmail() async => const Success(null);
}

void main() {
  group('AuthViewModel Simple Tests', () {
    late AuthViewModel viewModel;
    late SimpleAuthRepository repository;

    setUp(() {
      repository = SimpleAuthRepository();
      viewModel = AuthViewModel(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      );
    });

    group('Initial State', () {
      test('should start with initial state', () {
        expect(viewModel.state, equals(AuthState.initial));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.error, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.isAuthenticated, isFalse);
      });
    });

    group('Login Tests', () {
      test('should handle successful login', () async {
        // Arrange
        repository.setShouldSucceed(true);

        // Track state changes
        final states = <AuthState>[];
        viewModel.addListener(() {
          states.add(viewModel.state);
        });

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Wait for async operations to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(states, contains(AuthState.loading));
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.error, isNull);
      });

      test('should handle login failure', () async {
        // Arrange
        repository.setLoginResult(Failure(AuthenticationError('Invalid credentials')));

        // Act
        await viewModel.login('test@example.com', 'ValidPass123');

        // Wait for async operations to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<AuthenticationError>());
        expect(viewModel.currentUser, isNull);
      });

      test('should handle validation errors', () async {
        // Act - Invalid email format
        await viewModel.login('invalid-email', 'Password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
      });

      test('should handle empty inputs', () async {
        // Act
        await viewModel.login('', '');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
      });
    });

    group('Register Tests', () {
      test('should handle successful registration', () async {
        // Arrange
        repository.setShouldSucceed(true);

        // Act
        await viewModel.register('newuser@example.com', 'Password123', 'New User');

        // Wait for async operations to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.error, isNull);
      });

      test('should handle registration validation errors', () async {
        // Act - Invalid inputs
        await viewModel.register('', 'short', '');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
      });
    });

    group('Logout Tests', () {
      test('should handle successful logout', () async {
        // Arrange - Login first
        repository.setShouldSucceed(true);
        await viewModel.login('test@example.com', 'Password123');
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));

        // Act
        await viewModel.logout();
        await waitForAsyncOp();

        // Assert
        expect(viewModel.state, equals(AuthState.unauthenticated));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.error, isNull);
      });
    });

    group('Authentication Status Tests', () {
      test('should check authentication status', () async {
        // Arrange
        repository.setShouldSucceed(true);

        // Act
        await viewModel.checkAuthenticationStatus();

        // Assert
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
      });

      test('should handle no existing session', () async {
        // Arrange
        repository.setGetCurrentUserResult(Failure(AuthenticationError('No session')));

        // Act
        await viewModel.checkAuthenticationStatus();

        // Assert
        expect(viewModel.state, equals(AuthState.unauthenticated));
        expect(viewModel.currentUser, isNull);
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors', () async {
        // Arrange
        repository.setLoginResult(Failure(NetworkError('No internet')));

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<NetworkError>());
      });

      test('should handle server errors', () async {
        // Arrange
        repository.setLoginResult(Failure(ServerError('Server down', 500)));

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ServerError>());
      });

      test('should clear error when new operation starts', () async {
        // Arrange - Create error state
        repository.setLoginResult(Failure(AuthenticationError('First error')));
        await viewModel.login('test@example.com', 'WrongPass123');
        expect(viewModel.error, isNotNull);

        // Setup success for next operation
        repository.setLoginResult(
          Success(AuthToken(accessToken: 'success-token', refreshToken: 'success-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)))),
        );

        // Act
        await viewModel.login('test@example.com', 'Password123');
        await waitForAsyncOp();

        // Assert
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.error, isNull);
      });

      test('should use clearError method', () async {
        // Arrange - Create error state
        repository.setLoginResult(Failure(ValidationError('Test error')));
        await viewModel.login('invalid-email', 'Password123');
        await waitForAsyncOp(50);

        expect(viewModel.error, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.error, isNull);
      });
    });

    group('State Transitions Tests', () {
      test('should notify listeners on state changes', () async {
        // Arrange
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should handle multiple operations', () async {
        // Arrange
        repository.setShouldSucceed(true);

        // Act - Login, then logout, then login again
        await viewModel.login('test@example.com', 'Password123');
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));

        await viewModel.logout();
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.unauthenticated));

        await viewModel.login('test@example.com', 'Password123');
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
      });
    });

    group('Loading State Tests', () {
      test('should show loading state during operations', () async {
        // Arrange
        bool wasLoading = false;
        viewModel.addListener(() {
          if (viewModel.isLoading) {
            wasLoading = true;
          }
        });

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Assert
        expect(wasLoading, isTrue);
      });

      test('should not be loading after operation completes', () async {
        // Act
        await viewModel.login('test@example.com', 'Password123');
        await waitForAsyncOp();

        // Assert
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('Input Validation Tests', () {
      test('should validate email formats', () async {
        final testCases = [
          ('plainaddress', false),
          ('@missing.com', false),
          ('missing@.com', false),
          ('valid@example.com', true),
          ('user.name@domain.co.uk', true),
        ];

        for (final (email, shouldSucceed) in testCases) {
          // Reset state
          viewModel.clearError();

          // Act
          await viewModel.login(email, 'Password123');

          // Assert
          if (shouldSucceed) {
            expect(viewModel.state, isNot(equals(AuthState.error)), reason: 'Should accept valid email: $email');
          } else {
            expect(viewModel.state, equals(AuthState.error), reason: 'Should reject invalid email: $email');
            expect(viewModel.error, isA<ValidationError>(), reason: 'Should have validation error for: $email');
          }
        }
      });

      test('should validate password requirements', () async {
        final testCases = [
          ('short1', false), // Too short
          ('password', false), // No numbers
          ('12345678', false), // No letters
          ('Password123', true), // Valid
          ('mySecret123', true), // Valid
        ];

        for (final (password, shouldSucceed) in testCases) {
          // Reset state
          viewModel.clearError();

          // Act
          await viewModel.login('test@example.com', password);

          // Assert
          if (shouldSucceed) {
            expect(viewModel.state, isNot(equals(AuthState.error)), reason: 'Should accept valid password: $password');
          } else {
            expect(viewModel.state, equals(AuthState.error), reason: 'Should reject invalid password: $password');
            expect(viewModel.error, isA<ValidationError>(), reason: 'Should have validation error for: $password');
          }
        }
      });
    });

    tearDown(() {
      // Clean disposal is handled by test framework
      // Don't call dispose() manually to avoid "used after disposed" errors
    });
  });

  group('ViewModel Integration Scenarios', () {
    test('should handle complete user flow', () async {
      // Arrange
      final repository = SimpleAuthRepository();
      final viewModel = AuthViewModel(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      );

      // Act & Assert - Complete flow
      // 1. Start unauthenticated
      expect(viewModel.state, equals(AuthState.initial));

      // 2. Register new user
      await viewModel.register('newuser@example.com', 'Password123', 'New User');

      // Wait for async operations to complete
      await waitForAsyncOp();
      expect(viewModel.state, equals(AuthState.authenticated));
      expect(viewModel.currentUser?.name, equals('Test User')); // From mock

      // 3. Logout
      await viewModel.logout();
      await waitForAsyncOp();
      expect(viewModel.state, equals(AuthState.unauthenticated));
      expect(viewModel.currentUser, isNull);

      // 4. Login existing user
      await viewModel.login('newuser@example.com', 'Password123');
      await waitForAsyncOp();
      expect(viewModel.state, equals(AuthState.authenticated));
      expect(viewModel.currentUser, isNotNull);
    });

    test('should handle error recovery scenarios', () async {
      // Arrange
      final repository = SimpleAuthRepository();
      final viewModel = AuthViewModel(
        loginUseCase: LoginUseCase(repository),
        registerUseCase: RegisterUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
        getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      );

      // Act & Assert
      // 1. Fail login
      repository.setLoginResult(Failure(AuthenticationError('Invalid')));
      await viewModel.login('wrong@example.com', 'WrongPass123');
      expect(viewModel.state, equals(AuthState.error));

      // 2. Recover with successful login
      repository.setLoginResult(
        Success(AuthToken(accessToken: 'recovery-token', refreshToken: 'recovery-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)))),
      );
      await viewModel.login('correct@example.com', 'Password123');
      await waitForAsyncOp();
      expect(viewModel.state, equals(AuthState.authenticated));
      expect(viewModel.error, isNull);
    });
  });
}

/// **Test Helper Functions**
///
/// ฟังก์ชันช่วยเหลือสำหรับการทดสอบ
extension AuthViewModelTestExtensions on AuthViewModel {
  /// Wait for state to change to expected value or timeout
  Future<void> waitForState(AuthState expectedState, {Duration timeout = const Duration(seconds: 1)}) async {
    final completer = Completer<void>();
    late VoidCallback listener;

    listener = () {
      if (state == expectedState) {
        removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    };

    addListener(listener);

    // Set timeout
    Timer(timeout, () {
      removeListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('State did not change to $expectedState within $timeout'));
      }
    });

    return completer.future;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
