import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/features/auth/application/usecases/login_usecase.dart';
import 'package:blueprint_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';
import 'package:blueprint_application/core/error_handling.dart';

/// **Use Cases Tests**
///
/// ทดสอบ Application Layer - Business Use Cases
/// - Login use case with validation
/// - Error handling และ edge cases
/// - Repository interaction behavior
/// - Business logic validation

// Simple fake repository for testing
class FakeAuthRepository implements AuthRepository {
  Result<AuthToken>? _mockResult;
  Exception? _exceptionToThrow;
  int callCount = 0;
  String? expectedEmail;

  void setMockResult(Result<AuthToken> result) {
    _mockResult = result;
    _exceptionToThrow = null;
  }

  void setThrowException(Exception exception) {
    _exceptionToThrow = exception;
    _mockResult = null;
  }

  @override
  Future<Result<AuthToken>> login(Email email, Password password) async {
    callCount++;

    if (expectedEmail != null && email.value != expectedEmail) {
      return Failure(ValidationError('Email mismatch'));
    }

    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }

    return _mockResult ?? Failure(UnknownError('No mock result set'));
  }

  @override
  Future<Result<void>> logout() async {
    callCount++;
    return const Success(null);
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    callCount++;
    if (_exceptionToThrow != null) {
      throw _exceptionToThrow!;
    }
    return _mockResult ?? Failure(UnknownError('No mock result set'));
  }

  @override
  Future<bool> isAuthenticated() async {
    return true;
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    // Simulate clearing data
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    final user = User(id: 'test-user-id', email: 'test@example.com', name: 'Test User', createdAt: DateTime.now());
    return Success(user);
  }

  @override
  Future<Result<AuthToken>> register(Email email, Password password, Name name) async {
    callCount++;
    final token = AuthToken(accessToken: 'register-token', refreshToken: 'register-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));
    return Success(token);
  }

  @override
  Future<void> storeToken(AuthToken token) async {
    // Simulate storing token
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
  group('LoginUseCase Tests', () {
    late FakeAuthRepository fakeRepository;
    late LoginUseCase loginUseCase;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      loginUseCase = LoginUseCase(fakeRepository);
    });

    test('should return success when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final expectedToken = AuthToken(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      fakeRepository.setMockResult(Success(expectedToken));

      // Act
      final result = await loginUseCase.call(email, password);

      // Assert
      expect(result, isA<Success<AuthToken>>());
      if (result is Success<AuthToken>) {
        expect(result.data.accessToken, equals('access-token'));
        expect(result.data.refreshToken, equals('refresh-token'));
      }
      expect(fakeRepository.callCount, equals(1));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final networkError = NetworkError('Connection failed');

      fakeRepository.setMockResult(Failure(networkError));

      // Act
      final result = await loginUseCase.call(email, password);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<NetworkError>());
        expect(result.error.message, equals('Connection failed'));
      }
    });

    test('should return validation error for invalid email', () async {
      // Arrange
      const invalidEmail = 'invalid-email';
      const password = 'password123';

      // Act
      final result = await loginUseCase.call(invalidEmail, password);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<ValidationError>());
        expect(result.error.message, contains('Invalid email format'));
      }
      // Repository should not be called due to validation failure
      expect(fakeRepository.callCount, equals(0));
    });

    test('should return validation error for invalid password', () async {
      // Arrange
      const email = 'test@example.com';
      const invalidPassword = '123'; // Too short

      // Act
      final result = await loginUseCase.call(email, invalidPassword);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<ValidationError>());
        expect(result.error.message, contains('Password must be at least 8 characters long'));
      }
      // Repository should not be called due to validation failure
      expect(fakeRepository.callCount, equals(0));
    });

    test('should return validation error for empty email', () async {
      // Arrange
      const emptyEmail = '';
      const password = 'password123';

      // Act
      final result = await loginUseCase.call(emptyEmail, password);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<ValidationError>());
        expect(result.error.message, equals('Email cannot be empty'));
      }
    });

    test('should return validation error for empty password', () async {
      // Arrange
      const email = 'test@example.com';
      const emptyPassword = '';

      // Act
      final result = await loginUseCase.call(email, emptyPassword);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<ValidationError>());
        expect(result.error.message, equals('Password cannot be empty'));
      }
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      fakeRepository.setThrowException(Exception('Unexpected error'));

      // Act
      final result = await loginUseCase.call(email, password);

      // Assert
      expect(result, isA<Failure<AuthToken>>());
      if (result is Failure<AuthToken>) {
        expect(result.error, isA<UnknownError>());
        expect(result.error.message, contains('Login failed'));
      }
    });

    test('should normalize email before processing', () async {
      // Arrange
      const emailWithCaps = 'TEST@EXAMPLE.COM';
      const password = 'password123';
      final expectedToken = AuthToken(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      fakeRepository.expectedEmail = 'test@example.com'; // Normalized
      fakeRepository.setMockResult(Success(expectedToken));

      // Act
      final result = await loginUseCase.call(emailWithCaps, password);

      // Assert
      expect(result, isA<Success<AuthToken>>());
    });

    test('should handle password with special characters', () async {
      // Arrange
      const email = 'test@example.com';
      const specialPassword = 'P@ssw0rd!123';
      final expectedToken = AuthToken(
        accessToken: 'special-token',
        refreshToken: 'special-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      fakeRepository.setMockResult(Success(expectedToken));

      // Act
      final result = await loginUseCase.call(email, specialPassword);

      // Assert
      expect(result, isA<Success<AuthToken>>());
    });

    test('should handle very long valid inputs', () async {
      // Arrange
      final longEmail = '${'a' * 50}@${'domain' * 5}.com';
      final longPassword = 'password${'123' * 10}';
      final expectedToken = AuthToken(
        accessToken: 'long-token',
        refreshToken: 'long-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      fakeRepository.setMockResult(Success(expectedToken));

      // Act
      final result = await loginUseCase.call(longEmail, longPassword);

      // Assert
      expect(result, isA<Success<AuthToken>>());
    });
  });

  group('LoginUseCase Edge Cases', () {
    late FakeAuthRepository fakeRepository;
    late LoginUseCase loginUseCase;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      loginUseCase = LoginUseCase(fakeRepository);
    });

    test('should handle concurrent login calls', () async {
      // Arrange
      final token1 = AuthToken(accessToken: 'token1', refreshToken: 'refresh1', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      fakeRepository.setMockResult(Success(token1));

      // Act - Call login multiple times concurrently
      final futures = List.generate(3, (_) => loginUseCase.call('test@example.com', 'password123'));
      final results = await Future.wait(futures);

      // Assert
      expect(results.length, equals(3));
      for (final result in results) {
        expect(result, isA<Success<AuthToken>>());
      }
      expect(fakeRepository.callCount, equals(3));
    });

    test('should handle rapid successive calls', () async {
      // Arrange
      final token = AuthToken(accessToken: 'rapid-token', refreshToken: 'rapid-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      fakeRepository.setMockResult(Success(token));

      // Act - Call login rapidly
      final results = <Result<AuthToken>>[];
      for (int i = 0; i < 5; i++) {
        final result = await loginUseCase.call('test@example.com', 'password123');
        results.add(result);
      }

      // Assert
      expect(results.length, equals(5));
      for (final result in results) {
        expect(result, isA<Success<AuthToken>>());
      }
      expect(fakeRepository.callCount, equals(5));
    });

    test('should handle mixed valid and invalid credentials', () async {
      // Arrange
      final validToken = AuthToken(
        accessToken: 'valid-token',
        refreshToken: 'valid-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      fakeRepository.setMockResult(Success(validToken));

      // Act & Assert
      // Valid credentials
      final validResult = await loginUseCase.call('test@example.com', 'password123');
      expect(validResult, isA<Success<AuthToken>>());

      // Invalid email
      final invalidEmailResult = await loginUseCase.call('invalid-email', 'password123');
      expect(invalidEmailResult, isA<Failure<AuthToken>>());

      // Invalid password
      final invalidPasswordResult = await loginUseCase.call('test@example.com', '123');
      expect(invalidPasswordResult, isA<Failure<AuthToken>>());

      // Only valid call should reach repository
      expect(fakeRepository.callCount, equals(1));
    });

    test('should handle repository state changes between calls', () async {
      // Arrange
      final token1 = AuthToken(accessToken: 'token1', refreshToken: 'refresh1', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      final token2 = AuthToken(accessToken: 'token2', refreshToken: 'refresh2', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      // Act & Assert
      // First call succeeds
      fakeRepository.setMockResult(Success(token1));
      final result1 = await loginUseCase.call('test@example.com', 'password123');
      expect(result1, isA<Success<AuthToken>>());

      // Second call fails
      fakeRepository.setMockResult(Failure(AuthenticationError('Account locked')));
      final result2 = await loginUseCase.call('test@example.com', 'password123');
      expect(result2, isA<Failure<AuthToken>>());

      // Third call succeeds again
      fakeRepository.setMockResult(Success(token2));
      final result3 = await loginUseCase.call('test@example.com', 'password123');
      expect(result3, isA<Success<AuthToken>>());

      expect(fakeRepository.callCount, equals(3));
    });
  });

  group('Value Object Integration Tests', () {
    test('should properly validate email formats through use case', () async {
      // Arrange
      final fakeRepository = FakeAuthRepository();
      final loginUseCase = LoginUseCase(fakeRepository);

      final validEmails = ['user@domain.com', 'test.email@example.org', 'user+tag@gmail.com'];

      final invalidEmails = ['plainaddress', '@missingdomain.com', 'missing@domain'];

      final token = AuthToken(accessToken: 'test-token', refreshToken: 'test-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      fakeRepository.setMockResult(Success(token));

      // Act & Assert valid emails
      for (final email in validEmails) {
        final result = await loginUseCase.call(email, 'password123');
        expect(result, isA<Success<AuthToken>>(), reason: 'Should accept valid email: $email');
      }

      // Act & Assert invalid emails
      for (final email in invalidEmails) {
        final result = await loginUseCase.call(email, 'password123');
        expect(result, isA<Failure<AuthToken>>(), reason: 'Should reject invalid email: $email');
      }
    });

    test('should properly validate password requirements through use case', () async {
      // Arrange
      final fakeRepository = FakeAuthRepository();
      final loginUseCase = LoginUseCase(fakeRepository);

      final validPasswords = ['password1', 'mySecret123', 'c0mpl3xP@ss'];

      final invalidPasswords = [
        'short1', // Too short
        'password', // No numbers
        '12345678', // No letters
      ];

      final token = AuthToken(accessToken: 'test-token', refreshToken: 'test-refresh', expiresAt: DateTime.now().add(const Duration(hours: 1)));

      fakeRepository.setMockResult(Success(token));

      // Act & Assert valid passwords
      for (final password in validPasswords) {
        final result = await loginUseCase.call('test@example.com', password);
        expect(result, isA<Success<AuthToken>>(), reason: 'Should accept valid password: $password');
      }

      // Act & Assert invalid passwords
      for (final password in invalidPasswords) {
        final result = await loginUseCase.call('test@example.com', password);
        expect(result, isA<Failure<AuthToken>>(), reason: 'Should reject invalid password: $password');
      }
    });
  });
}
