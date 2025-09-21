import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blueprint_application/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:blueprint_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:blueprint_application/features/auth/data/models/auth_models.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';
import 'package:blueprint_application/core/error_handling.dart';

/// **Repository Tests**
///
/// ทดสอบ Data Layer - Repository Implementation
/// - การผสมผสานระหว่าง remote และ local data sources
/// - Error handling จาก data sources
/// - Data transformation (models ↔ entities)
/// - Local storage behavior
/// - Network failure scenarios

// Fake Remote Data Source
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  AuthResponse? _mockLoginResponse;
  Object? _exceptionToThrow; // Changed to Object to support AppError types
  int callCount = 0;

  void setMockLoginResponse(AuthResponse response) {
    _mockLoginResponse = response;
    _exceptionToThrow = null;
  }

  void setThrowException(Object exception) {
    // Changed to Object
    _exceptionToThrow = exception;
    _mockLoginResponse = null;
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    callCount++;

    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }

    return _mockLoginResponse ??
        AuthResponse(
          token: AuthTokenModel(
            accessToken: 'default-token',
            refreshToken: 'default-refresh',
            expiresAt: DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          ),
          user: UserModel(
            id: 'default-user',
            email: request.email,
            name: 'Default User',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    callCount++;

    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }

    return AuthResponse(
      token: AuthTokenModel(
        accessToken: 'register-token',
        refreshToken: 'register-refresh',
        expiresAt: DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      ),
      user: UserModel(
        id: 'register-user',
        email: request.email,
        name: request.name,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    callCount++;
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    callCount++;
    return UserModel(
      id: 'current-user',
      email: 'current@example.com',
      name: 'Current User',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    callCount++;

    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }

    return AuthTokenModel(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    callCount++;
  }

  @override
  Future<void> verifyEmail(String verificationCode, String accessToken) async {
    callCount++;
  }

  @override
  Future<void> resendVerificationEmail(String accessToken) async {
    callCount++;
  }
}

// Fake Local Data Source
class FakeAuthLocalDataSource implements AuthLocalDataSource {
  AuthTokenModel? _storedToken;
  UserModel? _storedUser;
  Object? _exceptionToThrow; // Changed to Object
  int callCount = 0;

  void setThrowException(Object exception) {
    // Changed to Object
    _exceptionToThrow = exception;
  }

  @override
  Future<AuthTokenModel?> getStoredToken() async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    return _storedToken;
  }

  @override
  Future<void> storeToken(AuthTokenModel token) async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    _storedToken = token;
  }

  @override
  Future<void> clearAuthData() async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    _storedToken = null;
    _storedUser = null;
  }

  @override
  Future<UserModel?> getStoredUser() async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    return _storedUser;
  }

  @override
  Future<void> storeUser(UserModel user) async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    _storedUser = user;
  }
}

void main() {
  group('AuthRepositoryImpl Tests', () {
    late AuthRepositoryImpl repository;
    late FakeAuthRemoteDataSource fakeRemoteDataSource;
    late FakeAuthLocalDataSource fakeLocalDataSource;

    setUp(() {
      fakeRemoteDataSource = FakeAuthRemoteDataSource();
      fakeLocalDataSource = FakeAuthLocalDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
        localDataSource: fakeLocalDataSource,
      );
    });

    group('Login Tests', () {
      test(
        'should return success and store data locally when remote login succeeds',
        () async {
          // Arrange
          final email = Email.create('test@example.com');
          final password = Password.create('password123');

          final expectedResponse = AuthResponse(
            token: AuthTokenModel(
              accessToken: 'login-token',
              refreshToken: 'login-refresh',
              expiresAt: DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String(),
            ),
            user: UserModel(
              id: 'login-user',
              email: 'test@example.com',
              name: 'Test User',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

          fakeRemoteDataSource.setMockLoginResponse(expectedResponse);

          // Act
          final result = await repository.login(email, password);

          // Assert
          expect(result, isA<Success<AuthToken>>());
          if (result is Success<AuthToken>) {
            expect(result.data.accessToken, equals('login-token'));
            expect(result.data.refreshToken, equals('login-refresh'));
          }

          // Verify remote was called
          expect(fakeRemoteDataSource.callCount, equals(1));

          // Verify local storage was called
          expect(
            fakeLocalDataSource.callCount,
            equals(2),
          ); // storeToken + storeUser
        },
      );

      test('should return failure when remote login fails', () async {
        // Arrange
        final email = Email.create('test@example.com');
        final password = Password.create('password123');

        fakeRemoteDataSource.setThrowException(
          AuthenticationError('Invalid credentials'),
        );

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<AuthenticationError>());
          expect(result.error.message, equals('Invalid credentials'));
        }

        // Verify remote was called
        expect(fakeRemoteDataSource.callCount, equals(1));

        // Verify local storage was not called
        expect(fakeLocalDataSource.callCount, equals(0));
      });

      test('should return failure when local storage fails', () async {
        // Arrange
        final email = Email.create('test@example.com');
        final password = Password.create('password123');

        final expectedResponse = AuthResponse(
          token: AuthTokenModel(
            accessToken: 'login-token',
            refreshToken: 'login-refresh',
            expiresAt: DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          ),
          user: UserModel(
            id: 'login-user',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        fakeRemoteDataSource.setMockLoginResponse(expectedResponse);
        fakeLocalDataSource.setThrowException(Exception('Storage failed'));

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<UnknownError>());
          expect(result.error.message, contains('Login failed'));
        }
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final email = Email.create('test@example.com');
        final password = Password.create('password123');

        fakeRemoteDataSource.setThrowException(
          NetworkError('No internet connection'),
        );

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<NetworkError>());
          expect(result.error.message, equals('No internet connection'));
        }
      });

      test('should handle server errors with proper error mapping', () async {
        // Arrange
        final email = Email.create('test@example.com');
        final password = Password.create('password123');

        fakeRemoteDataSource.setThrowException(
          ServerError('Internal server error', 500),
        );

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<ServerError>());
          final serverError = result.error as ServerError;
          expect(serverError.message, equals('Internal server error'));
          expect(serverError.statusCode, equals(500));
        }
      });
    });

    group('Register Tests', () {
      test('should return success when registration succeeds', () async {
        // Arrange
        final email = Email.create('newuser@example.com');
        final password = Password.create('newpassword123');
        final name = Name.create('New User');

        // Act
        final result = await repository.register(email, password, name);

        // Assert
        expect(result, isA<Success<AuthToken>>());
        if (result is Success<AuthToken>) {
          expect(result.data.accessToken, equals('register-token'));
          expect(result.data.refreshToken, equals('register-refresh'));
        }

        // Verify calls were made
        expect(fakeRemoteDataSource.callCount, equals(1));
        expect(
          fakeLocalDataSource.callCount,
          equals(2),
        ); // storeToken + storeUser
      });

      test('should handle duplicate email registration', () async {
        // Arrange
        final email = Email.create('existing@example.com');
        final password = Password.create('password123');
        final name = Name.create('Existing User');

        fakeRemoteDataSource.setThrowException(
          ValidationError('Email already exists'),
        );

        // Act
        final result = await repository.register(email, password, name);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<ValidationError>());
          expect(result.error.message, equals('Email already exists'));
        }
      });
    });

    group('Logout Tests', () {
      test('should clear local data when logout succeeds', () async {
        // Arrange - Set up a stored token so remote logout is called
        final storedToken = AuthTokenModel(
          accessToken: 'stored-token',
          refreshToken: 'stored-refresh',
          expiresAt: DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
        );
        fakeLocalDataSource._storedToken = storedToken;

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, isA<Success<void>>());

        // Verify remote logout was called
        expect(fakeRemoteDataSource.callCount, equals(1));

        // Verify local data was cleared
        expect(
          fakeLocalDataSource.callCount,
          equals(2),
        ); // getStoredToken + clearAuthData
      });
      test('should clear local data even when remote logout fails', () async {
        // Arrange
        fakeRemoteDataSource.setThrowException(NetworkError('Network timeout'));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result, isA<Success<void>>());

        // Verify local data was still cleared
        expect(
          fakeLocalDataSource.callCount,
          equals(2),
        ); // getStoredToken + clearAuthData
      });
    });

    group('GetCurrentUser Tests', () {
      test('should return user when stored token exists', () async {
        // Arrange
        final storedToken = AuthTokenModel(
          accessToken: 'stored-token',
          refreshToken: 'stored-refresh',
          expiresAt: DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
        );

        fakeLocalDataSource._storedToken = storedToken;

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Success<User>>());
        if (result is Success<User>) {
          expect(result.data.email, equals('current@example.com'));
          expect(result.data.name, equals('Current User'));
        }

        // Verify remote was called with token
        expect(fakeRemoteDataSource.callCount, equals(1));
      });

      test('should return failure when no token stored', () async {
        // Arrange - no stored token
        fakeLocalDataSource._storedToken = null;

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Failure<User>>());
        if (result is Failure<User>) {
          expect(result.error, isA<AuthenticationError>());
          expect(result.error.message, equals('No valid authentication token'));
        }

        // Verify remote was not called
        expect(fakeRemoteDataSource.callCount, equals(0));
      });

      test('should handle expired token', () async {
        // Arrange
        final expiredToken = AuthTokenModel(
          accessToken: 'expired-token',
          refreshToken: 'expired-refresh',
          expiresAt: DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        );

        fakeLocalDataSource._storedToken = expiredToken;

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Failure<User>>());
        if (result is Failure<User>) {
          expect(result.error, isA<AuthenticationError>());
          expect(result.error.message, equals('No valid authentication token'));
        }
      });
    });

    group('isAuthenticated Tests', () {
      test('should return true when valid token exists', () async {
        // Arrange
        final validToken = AuthTokenModel(
          accessToken: 'valid-token',
          refreshToken: 'valid-refresh',
          expiresAt: DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
        );

        fakeLocalDataSource._storedToken = validToken;

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no token exists', () async {
        // Arrange
        fakeLocalDataSource._storedToken = null;

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when token is expired', () async {
        // Arrange
        final expiredToken = AuthTokenModel(
          accessToken: 'expired-token',
          refreshToken: 'expired-refresh',
          expiresAt: DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        );

        fakeLocalDataSource._storedToken = expiredToken;

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });
    });

    group('Token Management Tests', () {
      test('should store and retrieve token correctly', () async {
        // Arrange
        final token = AuthToken(
          accessToken: 'test-token',
          refreshToken: 'test-refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act - Store token
        await repository.storeToken(token);
        final retrievedToken = await repository.getStoredToken();

        // Assert
        expect(retrievedToken, isNotNull);
        expect(retrievedToken!.accessToken, equals('test-token'));
        expect(retrievedToken.refreshToken, equals('test-refresh'));
      });

      test('should refresh token successfully', () async {
        // Arrange
        const oldRefreshToken = 'old-refresh-token';

        // Act
        final result = await repository.refreshToken(oldRefreshToken);

        // Assert
        expect(result, isA<Success<AuthToken>>());
        if (result is Success<AuthToken>) {
          expect(result.data.accessToken, equals('new-access-token'));
          expect(result.data.refreshToken, equals('new-refresh-token'));
        }

        // Verify remote was called
        expect(fakeRemoteDataSource.callCount, equals(1));

        // Verify new token was stored
        expect(fakeLocalDataSource.callCount, equals(1));
      });

      test('should handle refresh token failure', () async {
        // Arrange
        const oldRefreshToken = 'invalid-refresh-token';
        fakeRemoteDataSource.setThrowException(
          AuthenticationError('Invalid refresh token'),
        );

        // Act
        final result = await repository.refreshToken(oldRefreshToken);

        // Assert
        expect(result, isA<Failure<AuthToken>>());
        if (result is Failure<AuthToken>) {
          expect(result.error, isA<AuthenticationError>());
          expect(result.error.message, equals('Invalid refresh token'));
        }
      });
    });

    group('Data Consistency Tests', () {
      test(
        'should maintain data consistency across multiple operations',
        () async {
          // Arrange
          final email = Email.create('consistency@example.com');
          final password = Password.create('password123');

          // Act 1: Login
          final loginResult = await repository.login(email, password);
          expect(loginResult, isA<Success<AuthToken>>());

          // Act 2: Check authentication
          final isAuth1 = await repository.isAuthenticated();
          expect(isAuth1, isTrue);

          // Act 3: Get current user
          final userResult = await repository.getCurrentUser();
          expect(userResult, isA<Success<User>>());

          // Act 4: Logout
          final logoutResult = await repository.logout();
          expect(logoutResult, isA<Success<void>>());

          // Act 5: Check authentication after logout
          final isAuth2 = await repository.isAuthenticated();
          expect(isAuth2, isFalse);
        },
      );

      test('should handle concurrent operations safely', () async {
        // Arrange
        final email = Email.create('concurrent@example.com');
        final password = Password.create('password123');

        // Act - Multiple concurrent operations
        final futures = [
          repository.login(email, password),
          repository.isAuthenticated(),
          repository.getStoredToken(),
        ];

        final results = await Future.wait(futures);

        // Assert - All operations should complete without errors
        expect(results.length, equals(3));
        expect(results[0], isA<Success<AuthToken>>());
        // Note: isAuthenticated and getStoredToken might return different values
        // depending on timing, but they should not throw errors
      });
    });
  });

  group('Error Handling Edge Cases', () {
    late AuthRepositoryImpl repository;
    late FakeAuthRemoteDataSource fakeRemoteDataSource;
    late FakeAuthLocalDataSource fakeLocalDataSource;

    setUp(() {
      fakeRemoteDataSource = FakeAuthRemoteDataSource();
      fakeLocalDataSource = FakeAuthLocalDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
        localDataSource: fakeLocalDataSource,
      );
    });

    test('should handle malformed token data', () async {
      // Arrange
      final malformedToken = AuthTokenModel(
        accessToken: '',
        refreshToken: '',
        expiresAt: 'invalid-date',
      );

      fakeLocalDataSource._storedToken = malformedToken;

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isFalse);
    });

    test('should handle storage corruption gracefully', () async {
      // Arrange
      fakeLocalDataSource.setThrowException(Exception('Storage corrupted'));

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isFalse); // Should not throw, return false instead
    });

    test('should handle unexpected data types from remote', () async {
      // Arrange
      final email = Email.create('test@example.com');
      final password = Password.create('password123');

      fakeRemoteDataSource.setThrowException(
        Exception('Unexpected response format'),
      );

      // Act
      final result = await repository.login(email, password);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<UnknownError>());
        expect(result.error.message, contains('Login failed'));
      }
    });

    test('should handle very large token data', () async {
      // Arrange
      final largeTokenData = 'x' * 10000; // Very large token
      final largeToken = AuthTokenModel(
        accessToken: largeTokenData,
        refreshToken: largeTokenData,
        expiresAt: DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      );

      // Act & Assert - Should not crash
      await repository.storeToken(largeToken.toEntity());
      final retrievedToken = await repository.getStoredToken();

      expect(retrievedToken?.accessToken, equals(largeTokenData));
    });
  });
}
