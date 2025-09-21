import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';

/// **Value Objects Tests**
///
/// ทดสอบ Domain Value Objects ที่มี business rules และ validation
/// - Email validation และ normalization
/// - Password strength requirements
/// - Name validation และ formatting
/// - Error handling สำหรับ invalid inputs
/// - Equality และ immutability
void main() {
  group('Email Value Object Tests', () {
    test('should create valid email', () {
      // Arrange & Act
      final email = Email.create('test@example.com');

      // Assert
      expect(email.value, equals('test@example.com'));
      expect(email.toString(), equals('test@example.com'));
    });

    test('should normalize email to lowercase', () {
      // Arrange & Act
      final email = Email.create('TEST@EXAMPLE.COM');

      // Assert
      expect(email.value, equals('test@example.com'));
    });

    test('should trim whitespace from email', () {
      // Arrange & Act
      final email = Email.create('  test@example.com  ');

      // Assert
      expect(email.value, equals('test@example.com'));
    });

    test('should accept valid email formats', () {
      // Arrange
      const validEmails = [
        'user@domain.com',
        'test.email@example.org',
        'user+tag@gmail.com',
        'firstname.lastname@company.co.uk',
        'user123@test123.info',
        'a@b.co',
      ];

      // Act & Assert
      for (final emailString in validEmails) {
        expect(
          () => Email.create(emailString),
          returnsNormally,
          reason: 'Should accept valid email: $emailString',
        );
      }
    });

    test('should reject invalid email formats', () {
      // Arrange
      const invalidEmails = [
        'plainaddress',
        '@missingdomain.com',
        'missing@.com',
        'missing@domain',
        'spaces in@email.com',
        'double@@domain.com',
        '.starting.dot@domain.com',
        'ending.dot.@domain.com',
        'user@domain..com',
      ];

      // Act & Assert
      for (final emailString in invalidEmails) {
        expect(
          () => Email.create(emailString),
          throwsArgumentError,
          reason: 'Should reject invalid email: $emailString',
        );
      }
    });

    test('should throw error for empty email', () {
      // Act & Assert
      expect(() => Email.create(''), throwsArgumentError);
      expect(
        () => Email.create(''),
        throwsA(
          predicate(
            (e) => e is ArgumentError && e.message == 'Email cannot be empty',
          ),
        ),
      );
    });

    test('should support equality comparison', () {
      // Arrange
      final email1 = Email.create('test@example.com');
      final email2 = Email.create('TEST@EXAMPLE.COM'); // Different case
      final email3 = Email.create('different@example.com');

      // Act & Assert
      expect(email1, equals(email2)); // Case-insensitive equality
      expect(email1, isNot(equals(email3)));
      expect(email1.hashCode, equals(email2.hashCode));
      expect(email1.hashCode, isNot(equals(email3.hashCode)));
    });

    test('should be immutable', () {
      // Arrange
      final email = Email.create('immutable@example.com');
      final originalValue = email.value;

      // Act - Try to access and verify immutability
      final accessedValue = email.value;

      // Assert
      expect(accessedValue, equals(originalValue));
      expect(email.value, equals('immutable@example.com'));
    });
  });

  group('Password Value Object Tests', () {
    test('should create valid password', () {
      // Arrange & Act
      final password = Password.create('password123');

      // Assert
      expect(password.value, equals('password123'));
    });

    test('should hide password in toString', () {
      // Arrange & Act
      final password = Password.create('secret123');

      // Assert
      expect(
        password.toString(),
        equals('*********'),
      ); // 9 asterisks for 9 characters
    });

    test('should accept valid passwords', () {
      // Arrange
      const validPasswords = [
        'password1',
        'mySecret123',
        'c0mpl3xP@ss',
        'simple1password',
        'Test123456',
        'a1b2c3d4e5',
      ];

      // Act & Assert
      for (final passwordString in validPasswords) {
        expect(
          () => Password.create(passwordString),
          returnsNormally,
          reason: 'Should accept valid password: $passwordString',
        );
      }
    });

    test('should reject password shorter than 8 characters', () {
      // Arrange
      final shortPasswords = ['short1', '1234567', 'abc123', 'p1', 'test12'];

      // Act & Assert
      for (final passwordString in shortPasswords) {
        expect(
          () => Password.create(passwordString),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Password must be at least 8 characters long',
            ),
          ),
          reason: 'Should reject short password: $passwordString',
        );
      }
    });

    test('should reject password without letters', () {
      // Arrange
      final noLetterPasswords = [
        '12345678',
        '987654321',
        '11111111',
        r'!@#$%^&*',
      ];

      // Act & Assert
      for (final passwordString in noLetterPasswords) {
        expect(
          () => Password.create(passwordString),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message ==
                      'Password must contain at least one letter and one number',
            ),
          ),
          reason: 'Should reject password without letters: $passwordString',
        );
      }
    });

    test('should reject password without numbers', () {
      // Arrange
      final noNumberPasswords = [
        'passwordlong',
        'abcdefghij',
        'ALLCAPSLONGER',
        'mixedCaseLonger',
      ];

      // Act & Assert
      for (final passwordString in noNumberPasswords) {
        expect(
          () => Password.create(passwordString),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message ==
                      'Password must contain at least one letter and one number',
            ),
          ),
          reason: 'Should reject password without numbers: $passwordString',
        );
      }
    });

    test('should throw error for empty password', () {
      // Act & Assert
      expect(
        () => Password.create(''),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError && e.message == 'Password cannot be empty',
          ),
        ),
      );
    });

    test('should support equality comparison', () {
      // Arrange
      final password1 = Password.create('same123password');
      final password2 = Password.create('same123password');
      final password3 = Password.create('different456');

      // Act & Assert
      expect(password1, equals(password2));
      expect(password1, isNot(equals(password3)));
      expect(password1.hashCode, equals(password2.hashCode));
    });

    test('should be case-sensitive for equality', () {
      // Arrange
      final password1 = Password.create('Password123');
      final password2 = Password.create('password123');

      // Act & Assert
      expect(password1, isNot(equals(password2)));
    });
  });

  group('Name Value Object Tests', () {
    test('should create valid name', () {
      // Arrange & Act
      final name = Name.create('John Doe');

      // Assert
      expect(name.value, equals('John Doe'));
      expect(name.toString(), equals('John Doe'));
    });

    test('should trim whitespace from name', () {
      // Arrange & Act
      final name = Name.create('  John Smith  ');

      // Assert
      expect(name.value, equals('John Smith'));
    });

    test('should accept valid name formats', () {
      // Arrange
      const validNames = [
        'John',
        'John Doe',
        'Mary Jane',
        'Jean-Luc',
        "O'Connor",
        'Anna-Maria',
        'José García',
        '李明',
        'محمد احمد',
      ];

      // Act & Assert
      for (final nameString in validNames) {
        expect(
          () => Name.create(nameString),
          returnsNormally,
          reason: 'Should accept valid name: $nameString',
        );
      }
    });

    test('should reject invalid name formats', () {
      // Arrange
      const invalidNames = [
        'John123',
        'User@Name',
        'Name!',
        'Test#Name',
        'Name\$pecial',
        'Name%Value',
        'Name&Co',
        'Name*Star',
      ];

      // Act & Assert
      for (final nameString in invalidNames) {
        expect(
          () => Name.create(nameString),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Name contains invalid characters',
            ),
          ),
          reason: 'Should reject invalid name: $nameString',
        );
      }
    });

    test('should throw error for empty name', () {
      // Act & Assert
      expect(
        () => Name.create(''),
        throwsA(
          predicate(
            (e) => e is ArgumentError && e.message == 'Name cannot be empty',
          ),
        ),
      );

      expect(
        () => Name.create('   '),
        throwsA(
          predicate(
            (e) => e is ArgumentError && e.message == 'Name cannot be empty',
          ),
        ),
      );
    });

    test('should throw error for name too short', () {
      // Act & Assert
      expect(
        () => Name.create('A'),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'Name must be at least 2 characters long',
          ),
        ),
      );
    });

    test('should throw error for name too long', () {
      // Arrange
      final longName = 'A' * 51; // 51 characters

      // Act & Assert
      expect(
        () => Name.create(longName),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message == 'Name cannot exceed 50 characters',
          ),
        ),
      );
    });

    test('should accept name at maximum length', () {
      // Arrange
      final maxLengthName = 'A' * 50; // Exactly 50 characters

      // Act & Assert
      expect(() => Name.create(maxLengthName), returnsNormally);
    });

    test('should support equality comparison', () {
      // Arrange
      final name1 = Name.create('John Doe');
      final name2 = Name.create('  John Doe  '); // With whitespace
      final name3 = Name.create('Jane Doe');

      // Act & Assert
      expect(name1, equals(name2)); // Whitespace trimmed
      expect(name1, isNot(equals(name3)));
      expect(name1.hashCode, equals(name2.hashCode));
    });

    test('should be case-sensitive for equality', () {
      // Arrange
      final name1 = Name.create('John Doe');
      final name2 = Name.create('john doe');

      // Act & Assert
      expect(name1, isNot(equals(name2)));
    });
  });

  group('Value Objects Integration Tests', () {
    test('should work together in user creation scenario', () {
      // Arrange & Act
      final email = Email.create('user@example.com');
      final password = Password.create('securePass123');
      final name = Name.create('Test User');

      // Assert
      expect(email.value, equals('user@example.com'));
      expect(password.value, equals('securePass123'));
      expect(name.value, equals('Test User'));
    });

    test('should maintain immutability across all value objects', () {
      // Arrange
      final email = Email.create('test@example.com');
      final password = Password.create('password123');
      final name = Name.create('Test User');

      // Act - Store original values
      final originalEmail = email.value;
      final originalPassword = password.value;
      final originalName = name.value;

      // Assert - Values should remain unchanged
      expect(email.value, equals(originalEmail));
      expect(password.value, equals(originalPassword));
      expect(name.value, equals(originalName));
    });

    test('should handle edge cases consistently', () {
      // Test minimum valid values
      expect(() => Email.create('a@b.co'), returnsNormally);
      expect(() => Password.create('test1234'), returnsNormally);
      expect(() => Name.create('Jo'), returnsNormally);

      // Test maximum valid values
      expect(
        () => Email.create('very.long.email.address@very.long.domain.name.com'),
        returnsNormally,
      );
      expect(
        () => Password.create('verylongpasswordwithmanycharacters123'),
        returnsNormally,
      );
      expect(() => Name.create('A' * 50), returnsNormally);
    });
  });
}
