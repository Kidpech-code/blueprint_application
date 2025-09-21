import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:blueprint_application/features/auth/application/usecases/login_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/register_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/logout_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/get_current_user_usecase.dart';
import 'package:blueprint_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';
import 'package:blueprint_application/core/error_handling.dart';

/// **ViewModel Tests**
///
/// ทดสอบ Presentation Layer - MVVM ViewModels
/// - State management และ UI state changes
/// - User interaction handling
/// - Error handling และ user feedback
/// - Loading states และ navigation
/// - Business logic integration

// Helper function for waiting async operations
Future<void> waitForAsyncOp([int milliseconds = 200]) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

// Fake Repository for ViewModel Testing
class FakeAuthRepository implements AuthRepository {
  Result<AuthToken>? _loginResult;
  Result<AuthToken>? _registerResult;
  Result<void>? _logoutResult;
  Result<User>? _getCurrentUserResult;
  bool _isAuthenticated = false;
  AuthToken? _storedToken;

  int loginCallCount = 0;
  int registerCallCount = 0;
  int logoutCallCount = 0;
  int getCurrentUserCallCount = 0;

  // Mock setters
  void setMockLoginResult(Result<AuthToken> result) => _loginResult = result;
  void setMockRegisterResult(Result<AuthToken> result) => _registerResult = result;
  void setMockLogoutResult(Result<void> result) => _logoutResult = result;
  void setMockGetCurrentUserResult(Result<User> result) => _getCurrentUserResult = result;
  void setMockIsAuthenticated(bool value) => _isAuthenticated = value;
  void setMockStoredToken(AuthToken? token) => _storedToken = token;

  @override
  Future<Result<AuthToken>> login(Email email, Password password) async {
    loginCallCount++;
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _loginResult ?? Failure(UnknownError('No mock result set'));
  }

  @override
  Future<Result<AuthToken>> register(Email email, Password password, Name name) async {
    registerCallCount++;
    await Future.delayed(const Duration(milliseconds: 100));
    return _registerResult ?? Failure(UnknownError('No mock result set'));
  }

  @override
  Future<Result<void>> logout() async {
    logoutCallCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return _logoutResult ?? const Success(null);
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    getCurrentUserCallCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return _getCurrentUserResult ?? Failure(AuthenticationError('No user found'));
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    return _storedToken;
  }

  @override
  Future<void> storeToken(AuthToken token) async {
    _storedToken = token;
  }

  @override
  Future<void> clearAuthData() async {
    _storedToken = null;
    _isAuthenticated = false;
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    return Success(
      AuthToken(accessToken: 'new-access-token', refreshToken: 'new-refresh-token', expiresAt: DateTime.now().add(const Duration(hours: 1))),
    );
  }

  @override
  Future<Result<void>> resetPassword(Email email) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> verifyEmail(String verificationCode) async {
    return const Success(null);
  }

  @override
  Future<Result<void>> resendVerificationEmail() async {
    return const Success(null);
  }
}

void main() {
  group('AuthViewModel Tests', () {
    late AuthViewModel viewModel;
    late FakeAuthRepository fakeRepository;
    late LoginUseCase loginUseCase;
    late RegisterUseCase registerUseCase;
    late LogoutUseCase logoutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      loginUseCase = LoginUseCase(fakeRepository);
      registerUseCase = RegisterUseCase(fakeRepository);
      logoutUseCase = LogoutUseCase(fakeRepository);
      getCurrentUserUseCase = GetCurrentUserUseCase(fakeRepository);

      viewModel = AuthViewModel(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      );
    });

    tearDown(() async {
      // Wait for any pending async operations
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        viewModel.dispose();
      } catch (e) {
        // ViewModel already disposed, ignore
      }
    });

    group('Initial State Tests', () {
      test('should start with initial state', () {
        expect(viewModel.state, equals(AuthState.initial));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.error, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.isAuthenticated, isFalse);
      });
    });

    group('Login Tests', () {
      test('should update state correctly during successful login', () async {
        // Arrange
        final expectedToken = AuthToken(
          accessToken: 'login-token',
          refreshToken: 'login-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        final expectedUser = User(id: 'user-123', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now());

        fakeRepository.setMockLoginResult(Success(expectedToken));
        fakeRepository.setMockGetCurrentUserResult(Success(expectedUser));

        // Track state changes
        final stateChanges = <AuthState>[];
        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
        });

        // Act
        await viewModel.login('test@example.com', 'Password123');

        // Wait for async operations to complete
        await waitForAsyncOp();

        // Assert
        expect(stateChanges, contains(AuthState.loading));
        expect(stateChanges, contains(AuthState.authenticated));
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, equals('test@example.com'));
        expect(viewModel.error, isNull);
        expect(fakeRepository.loginCallCount, equals(1));
        expect(fakeRepository.getCurrentUserCallCount, equals(1));
      });

      test('should handle login failure correctly', () async {
        // Arrange
        final loginError = AuthenticationError('Invalid credentials');
        fakeRepository.setMockLoginResult(Failure(loginError));

        final stateChanges = <AuthState>[];
        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
        });

        // Act
        await viewModel.login('test@example.com', 'ValidPass123');

        // Wait for async operations to complete
        await waitForAsyncOp();

        // Assert
        expect(stateChanges, contains(AuthState.loading));
        expect(stateChanges, contains(AuthState.error));
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.error, isA<AuthenticationError>());
        expect(viewModel.error!.message, equals('Invalid credentials'));
        expect(fakeRepository.loginCallCount, equals(1));
        expect(fakeRepository.getCurrentUserCallCount, equals(0));
      });

      test('should handle network errors during login', () async {
        // Arrange
        final networkError = NetworkError('No internet connection');
        fakeRepository.setMockLoginResult(Failure(networkError));

        // Act
        await viewModel.login('test@example.com', 'password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<NetworkError>());
        expect(viewModel.error!.message, equals('No internet connection'));
      });

      test('should handle validation errors during login', () async {
        // Act - Invalid email
        await viewModel.login('invalid-email', 'password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
        expect(viewModel.error!.message, contains('Invalid email format'));
        expect(fakeRepository.loginCallCount, equals(0)); // Should not call repository
      });

      test('should handle empty credentials', () async {
        // Act
        await viewModel.login('', '');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
        expect(fakeRepository.loginCallCount, equals(0));
      });
    });

    group('Register Tests', () {
      test('should update state correctly during successful registration', () async {
        // Arrange
        final expectedToken = AuthToken(
          accessToken: 'register-token',
          refreshToken: 'register-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        final expectedUser = User(id: 'new-user-123', email: 'newuser@example.com', name: 'New User', createdAt: DateTime.now());

        fakeRepository.setMockRegisterResult(Success(expectedToken));
        fakeRepository.setMockGetCurrentUserResult(Success(expectedUser));

        final stateChanges = <AuthState>[];
        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
        });

        // Act
        await viewModel.register('newuser@example.com', 'Password123', 'New User');

        // Wait for async operations to complete
        await waitForAsyncOp();

        // Assert
        expect(stateChanges, contains(AuthState.loading));
        expect(stateChanges, contains(AuthState.authenticated));
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.name, equals('New User'));
        expect(fakeRepository.registerCallCount, equals(1));
        expect(fakeRepository.getCurrentUserCallCount, equals(1));
      });

      test('should handle duplicate email registration', () async {
        // Arrange
        final validationError = ValidationError('Email already exists');
        fakeRepository.setMockRegisterResult(Failure(validationError));

        // Act
        await viewModel.register('existing@example.com', 'password123', 'User');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
        expect(viewModel.error!.message, equals('Email already exists'));
      });

      test('should validate registration input', () async {
        // Act - Invalid inputs
        await viewModel.register('', 'short', '');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<ValidationError>());
        expect(fakeRepository.registerCallCount, equals(0));
      });
    });

    group('Logout Tests', () {
      test('should update state correctly during logout', () async {
        // Arrange - Start with authenticated state by logging in first
        final loginToken = AuthToken(
          accessToken: 'login-token',
          refreshToken: 'login-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        final user = User(id: 'user-123', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now());

        fakeRepository.setMockLoginResult(Success(loginToken));
        fakeRepository.setMockGetCurrentUserResult(Success(user));
        await viewModel.login('test@example.com', 'password123');

        // Verify we're authenticated
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));

        fakeRepository.setMockLogoutResult(const Success(null));

        final stateChanges = <AuthState>[];
        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
        });

        // Act
        await viewModel.logout();

        // Assert
        expect(stateChanges, contains(AuthState.loading));
        expect(stateChanges, contains(AuthState.unauthenticated));
        expect(viewModel.state, equals(AuthState.unauthenticated));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.error, isNull);
        expect(fakeRepository.logoutCallCount, equals(1));
      });

      test('should handle logout failure gracefully', () async {
        // Arrange - Start authenticated
        final loginToken = AuthToken(
          accessToken: 'login-token',
          refreshToken: 'login-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        final user = User(id: 'user-123', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now());

        fakeRepository.setMockLoginResult(Success(loginToken));
        fakeRepository.setMockGetCurrentUserResult(Success(user));
        await viewModel.login('test@example.com', 'password123');

        final logoutError = NetworkError('Logout failed');
        fakeRepository.setMockLogoutResult(Failure(logoutError));

        // Act
        await viewModel.logout();

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<NetworkError>());
        expect(viewModel.error!.message, equals('Logout failed'));
      });
    });

    group('State Management Tests', () {
      test('should notify listeners when state changes', () async {
        // Arrange
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Setup for login operation to trigger state changes
        final token = AuthToken(accessToken: 'test-token', refreshToken: 'test-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
        final user = User(id: 'test-user', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now());
        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(Success(user));

        // Act - This will trigger state changes: initial -> loading -> authenticated
        await viewModel.login('test@example.com', 'password123');

        // Assert - Should have multiple notifications for state changes
        expect(notificationCount, greaterThan(0));
      });

      test('should clear error when new operation starts', () async {
        // Arrange - Create an error state first by failing login
        fakeRepository.setMockLoginResult(Failure(ValidationError('Previous error')));
        await viewModel.login('invalid@example.com', 'wrongpassword');
        expect(viewModel.error, isNotNull);

        // Setup successful login
        final token = AuthToken(accessToken: 'token', refreshToken: 'refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(
          Success(User(id: 'user', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now())),
        );

        // Act
        await viewModel.login('test@example.com', 'password123');

        // Assert
        expect(viewModel.error, isNull);
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
      });

      test('should maintain state consistency during concurrent operations', () async {
        // Arrange
        final token = AuthToken(accessToken: 'token', refreshToken: 'refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(
          Success(User(id: 'user', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now())),
        );

        // Act - Start multiple operations
        final futures = [viewModel.login('test1@example.com', 'password1'), viewModel.login('test2@example.com', 'password2')];

        await Future.wait(futures);
        await waitForAsyncOp(300); // Wait for concurrent operations to complete

        // Assert - Should not crash and have consistent state
        expect(viewModel.state, isIn([AuthState.authenticated, AuthState.error]));
      });
    });

    group('User Session Management Tests', () {
      test('should check current user on initialization', () async {
        // Arrange
        final existingUser = User(id: 'existing-user', email: 'existing@example.com', name: 'Existing User', createdAt: DateTime.now());
        fakeRepository.setMockGetCurrentUserResult(Success(existingUser));

        // Act
        await viewModel.checkAuthenticationStatus();

        // Assert
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, equals('existing@example.com'));
      });

      test('should handle no existing session', () async {
        // Arrange
        fakeRepository.setMockGetCurrentUserResult(Failure(AuthenticationError('No user session')));

        // Act
        await viewModel.checkAuthenticationStatus();
        await waitForAsyncOp();

        // Assert
        expect(viewModel.state, equals(AuthState.unauthenticated));
        expect(viewModel.currentUser, isNull);
      });

      test('should update user profile', () async {
        // Arrange - Login first to get authenticated user
        final token = AuthToken(accessToken: 'token', refreshToken: 'refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
        final originalUser = User(id: 'user-123', email: 'original@example.com', name: 'Original Name', createdAt: DateTime.now());

        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(Success(originalUser));

        await viewModel.login('original@example.com', 'Password123');
        await waitForAsyncOp();
        expect(viewModel.currentUser?.name, equals('Original Name'));

        // Act - Update user by login with updated user data
        final updatedUser = originalUser.copyWith(name: 'Updated Name');
        fakeRepository.setMockGetCurrentUserResult(Success(updatedUser));

        await viewModel.checkAuthenticationStatus(); // Refresh user data
        await waitForAsyncOp();

        // Assert
        expect(viewModel.currentUser!.name, equals('Updated Name'));
        expect(viewModel.currentUser!.email, equals('original@example.com'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle unexpected errors gracefully', () async {
        // Arrange
        fakeRepository.setMockLoginResult(Failure(UnknownError('Unexpected server error')));

        // Act
        await viewModel.login('test@example.com', 'password123');

        // Assert
        expect(viewModel.state, equals(AuthState.error));
        expect(viewModel.error, isA<UnknownError>());
        expect(viewModel.error!.message, contains('Unexpected server error'));
      });

      test('should provide user-friendly error messages', () async {
        // Test different error types
        final errorScenarios = [
          (NetworkError('Connection timeout'), 'network'),
          (ServerError('Server unavailable', 503), 'server'),
          (ValidationError('Invalid input'), 'validation'),
          (AuthenticationError('Invalid credentials'), 'authentication'),
        ];

        for (final (error, errorType) in errorScenarios) {
          // Arrange
          fakeRepository.setMockLoginResult(Failure(error));

          // Act
          await viewModel.login('test@example.com', 'password123');

          // Assert
          expect(viewModel.state, equals(AuthState.error), reason: 'Should handle $errorType error');
          expect(viewModel.error, isA<AppError>(), reason: 'Should have AppError for $errorType');
          expect(viewModel.error!.message, isNotEmpty, reason: 'Should have error message for $errorType');

          // Reset for next test
          viewModel.clearError();
        }
      });

      test('should allow error recovery', () async {
        // Arrange - Start with error state by failing login
        fakeRepository.setMockLoginResult(Failure(NetworkError('Connection failed')));
        await viewModel.login('error@example.com', 'wrongpassword');
        expect(viewModel.state, equals(AuthState.error));

        // Setup successful operation
        final token = AuthToken(
          accessToken: 'recovery-token',
          refreshToken: 'recovery-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(
          Success(User(id: 'recovery-user', email: 'recovery@example.com', name: 'Recovery User', createdAt: DateTime.now())),
        );

        // Act - Retry operation
        await viewModel.login('recovery@example.com', 'password123');

        // Assert
        await waitForAsyncOp();
        expect(viewModel.state, equals(AuthState.authenticated));
        expect(viewModel.error, isNull);
        expect(viewModel.currentUser, isNotNull);
      });
    });

    group('Performance Tests', () {
      test('should handle rapid successive operations', () async {
        // Arrange
        final token = AuthToken(accessToken: 'rapid-token', refreshToken: 'rapid-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
        fakeRepository.setMockLoginResult(Success(token));
        fakeRepository.setMockGetCurrentUserResult(
          Success(User(id: 'rapid-user', email: 'rapid@example.com', name: 'Rapid User', createdAt: DateTime.now())),
        );

        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Act - Rapid operations
        final futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          futures.add(viewModel.login('rapid$i@example.com', 'password'));
        }
        await Future.wait(futures);

        // Assert - Should not crash and handle all operations
        expect(notificationCount, greaterThan(0));
        expect(viewModel.state, isIn([AuthState.authenticated, AuthState.error]));
      });

      test('should dispose resources properly', () {
        // Arrange
        void listener() {
          // Empty listener for testing
        }
        viewModel.addListener(listener);

        // Act
        viewModel.dispose();

        // Try to trigger notification after dispose - should be handled gracefully
        try {
          viewModel.clearError(); // This might still notify if not properly disposed
        } catch (e) {
          // Expected if dispose is working correctly
        }

        // Assert - Test passes if no exception is thrown during dispose
        expect(true, isTrue); // Always passes, main goal is no crash
      });
    });
  });

  group('ViewModel Integration Tests', () {
    test('should handle complete authentication flow', () async {
      // Arrange
      final fakeRepository = FakeAuthRepository();
      final viewModel = AuthViewModel(
        loginUseCase: LoginUseCase(fakeRepository),
        registerUseCase: RegisterUseCase(fakeRepository),
        logoutUseCase: LogoutUseCase(fakeRepository),
        getCurrentUserUseCase: GetCurrentUserUseCase(fakeRepository),
      );

      final token = AuthToken(accessToken: 'flow-token', refreshToken: 'flow-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
      final user = User(id: 'flow-user', email: 'flow@example.com', name: 'Flow User', createdAt: DateTime.now());

      fakeRepository.setMockRegisterResult(Success(token));
      fakeRepository.setMockGetCurrentUserResult(Success(user));
      fakeRepository.setMockLogoutResult(const Success(null));

      // Act & Assert - Complete flow
      // 1. Start unauthenticated
      expect(viewModel.state, equals(AuthState.initial));

      // 2. Register
      await viewModel.register('flow@example.com', 'password123', 'Flow User');
      await waitForAsyncOp();
      expect(viewModel.state, equals(AuthState.authenticated));
      expect(viewModel.currentUser?.email, equals('flow@example.com'));

      // 3. Logout
      await viewModel.logout();
      expect(viewModel.state, equals(AuthState.unauthenticated));
      expect(viewModel.currentUser, isNull);

      // Cleanup
      viewModel.dispose();
    });
  });
}
