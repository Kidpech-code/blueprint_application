import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';

/// **Domain Entities Tests**
///
/// ทดสอบ Business Objects หลักของระบบ Authentication
/// - การสร้าง entities
/// - การเปรียบเทียบ entities (equality)
/// - Business logic validation
/// - Entity behavior and methods
void main() {
  group('User Entity Tests', () {
    final testDateTime = DateTime.parse('2024-01-01T00:00:00Z');
    final testUser = User(
      id: 'test-user-123',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: testDateTime,
    );

    test('should create user with correct properties', () {
      // Act & Assert
      expect(testUser.id, equals('test-user-123'));
      expect(testUser.email, equals('test@example.com'));
      expect(testUser.name, equals('Test User'));
      expect(testUser.createdAt, equals(testDateTime));
      expect(testUser.profileImage, isNull);
      expect(testUser.lastLoginAt, isNull);
    });

    test('should support equality comparison', () {
      // Arrange
      final createdAt = DateTime.parse('2024-01-01T00:00:00Z');

      final user1 = User(
        id: 'user-1',
        email: 'user@test.com',
        name: 'User One',
        createdAt: createdAt,
      );

      final user2 = User(
        id: 'user-1',
        email: 'user@test.com',
        name: 'User One',
        createdAt: createdAt,
      );

      final user3 = User(
        id: 'user-2',
        email: 'user@test.com',
        name: 'User One',
        createdAt: createdAt,
      );

      // Act & Assert
      expect(user1, equals(user2)); // Same properties
      expect(user1, isNot(equals(user3))); // Different ID
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });

    test('should create user with optional profile image', () {
      // Arrange
      final userWithImage = User(
        id: 'test-user-456',
        email: 'image@example.com',
        name: 'Image User',
        profileImage: 'https://example.com/avatar.jpg',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act & Assert
      expect(
        userWithImage.profileImage,
        equals('https://example.com/avatar.jpg'),
      );
    });

    test('should handle null profile image gracefully', () {
      // Arrange
      final userWithoutImage = User(
        id: 'test-user-789',
        email: 'noimage@example.com',
        name: 'No Image User',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act & Assert
      expect(userWithoutImage.profileImage, isNull);
    });

    test('should create user with last login time', () {
      // Arrange
      final createdAt = DateTime.parse('2024-01-01T00:00:00Z');
      final lastLoginAt = DateTime.parse('2024-01-15T12:30:00Z');

      final userWithLogin = User(
        id: 'login-user',
        email: 'login@example.com',
        name: 'Login User',
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      // Act & Assert
      expect(userWithLogin.lastLoginAt, equals(lastLoginAt));
    });

    test('should create user with copy constructor', () {
      // Arrange
      final originalUser = User(
        id: 'original-user',
        email: 'original@example.com',
        name: 'Original User',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act
      final updatedUser = originalUser.copyWith(
        name: 'Updated User',
        profileImage: 'https://example.com/new-avatar.jpg',
      );

      // Assert
      expect(updatedUser.id, equals(originalUser.id));
      expect(updatedUser.email, equals(originalUser.email));
      expect(updatedUser.name, equals('Updated User'));
      expect(
        updatedUser.profileImage,
        equals('https://example.com/new-avatar.jpg'),
      );
      expect(updatedUser.createdAt, equals(originalUser.createdAt));
    });

    test('should maintain immutability with copyWith', () {
      // Arrange
      final originalUser = User(
        id: 'immutable-user',
        email: 'immutable@example.com',
        name: 'Immutable User',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act
      final modifiedUser = originalUser.copyWith(name: 'Modified Name');

      // Assert
      expect(originalUser.name, equals('Immutable User'));
      expect(modifiedUser.name, equals('Modified Name'));
      expect(
        originalUser.id,
        equals(modifiedUser.id),
      ); // Other properties remain same
    });
  });

  group('AuthToken Entity Tests', () {
    final testExpiresAt = DateTime.parse('2024-12-31T23:59:59Z');
    final testToken = AuthToken(
      accessToken: 'access-token-123',
      refreshToken: 'refresh-token-456',
      expiresAt: testExpiresAt,
    );

    test('should create auth token with correct properties', () {
      // Act & Assert
      expect(testToken.accessToken, equals('access-token-123'));
      expect(testToken.refreshToken, equals('refresh-token-456'));
      expect(testToken.expiresAt, equals(testExpiresAt));
    });

    test('should support equality comparison', () {
      // Arrange
      final expiresAt = DateTime.parse('2024-01-01T00:00:00Z');

      final token1 = AuthToken(
        accessToken: 'token-a',
        refreshToken: 'refresh-a',
        expiresAt: expiresAt,
      );

      final token2 = AuthToken(
        accessToken: 'token-a',
        refreshToken: 'refresh-a',
        expiresAt: expiresAt,
      );

      final token3 = AuthToken(
        accessToken: 'token-b',
        refreshToken: 'refresh-a',
        expiresAt: expiresAt,
      );

      // Act & Assert
      expect(token1, equals(token2));
      expect(token1, isNot(equals(token3)));
      expect(token1.hashCode, equals(token2.hashCode));
    });

    test('should validate token expiration - not expired', () {
      // Arrange
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final validToken = AuthToken(
        accessToken: 'valid-token',
        refreshToken: 'refresh-token',
        expiresAt: futureTime,
      );

      // Act & Assert
      expect(validToken.isExpired, isFalse);
    });

    test('should validate token expiration - expired', () {
      // Arrange
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final expiredToken = AuthToken(
        accessToken: 'expired-token',
        refreshToken: 'refresh-token',
        expiresAt: pastTime,
      );

      // Act & Assert
      expect(expiredToken.isExpired, isTrue);
    });

    test('should validate token expiration - exactly now', () {
      // Arrange
      final now = DateTime.now();
      final exactToken = AuthToken(
        accessToken: 'exact-token',
        refreshToken: 'refresh-token',
        expiresAt: now,
      );

      // Act & Assert
      // Token is considered expired if current time is after OR equal to expiry
      expect(exactToken.isExpired, isTrue);
    });

    test('should create copy with updated properties', () {
      // Arrange
      final originalToken = AuthToken(
        accessToken: 'original-access',
        refreshToken: 'original-refresh',
        expiresAt: DateTime.parse('2024-06-01T00:00:00Z'),
      );

      // Act
      final updatedToken = originalToken.copyWith(
        accessToken: 'new-access-token',
        expiresAt: DateTime.parse('2024-12-01T00:00:00Z'),
      );

      // Assert
      expect(updatedToken.accessToken, equals('new-access-token'));
      expect(
        updatedToken.refreshToken,
        equals('original-refresh'),
      ); // Unchanged
      expect(
        updatedToken.expiresAt,
        equals(DateTime.parse('2024-12-01T00:00:00Z')),
      );
    });

    test('should maintain immutability with copyWith', () {
      // Arrange
      final originalToken = AuthToken(
        accessToken: 'immutable-access',
        refreshToken: 'immutable-refresh',
        expiresAt: DateTime.parse('2024-06-01T00:00:00Z'),
      );

      // Act
      final newToken = originalToken.copyWith(accessToken: 'modified-access');

      // Assert
      expect(originalToken.accessToken, equals('immutable-access'));
      expect(newToken.accessToken, equals('modified-access'));
      expect(originalToken.refreshToken, equals(newToken.refreshToken));
    });
  });

  group('Edge Cases and Error Conditions', () {
    test('should handle empty string values in User', () {
      // Arrange & Act
      final userWithEmptyStrings = User(
        id: '',
        email: '',
        name: '',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Assert
      expect(userWithEmptyStrings.id, equals(''));
      expect(userWithEmptyStrings.email, equals(''));
      expect(userWithEmptyStrings.name, equals(''));
    });

    test('should handle empty string values in AuthToken', () {
      // Arrange & Act
      final tokenWithEmptyStrings = AuthToken(
        accessToken: '',
        refreshToken: '',
        expiresAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Assert
      expect(tokenWithEmptyStrings.accessToken, equals(''));
      expect(tokenWithEmptyStrings.refreshToken, equals(''));
    });

    test('should handle far future dates', () {
      // Arrange
      final farFutureDate = DateTime.parse('2099-12-31T23:59:59Z');
      final futureToken = AuthToken(
        accessToken: 'future-token',
        refreshToken: 'future-refresh',
        expiresAt: farFutureDate,
      );

      // Act & Assert
      expect(futureToken.expiresAt, equals(farFutureDate));
      expect(futureToken.isExpired, isFalse);
    });

    test('should handle very old dates', () {
      // Arrange
      final veryOldDate = DateTime.parse('1970-01-01T00:00:00Z');
      final oldUser = User(
        id: 'old-user',
        email: 'old@example.com',
        name: 'Old User',
        createdAt: veryOldDate,
      );

      // Act & Assert
      expect(oldUser.createdAt, equals(veryOldDate));
    });
  });
}
