// Value Objects for Auth Domain
class Email {
  final String value;

  const Email._(this.value);

  factory Email.create(String email) {
    // Trim whitespace first
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      throw ArgumentError('Invalid email format');
    }

    // Additional validation: no consecutive dots, no dots at start/end
    if (trimmedEmail.contains('..') ||
        trimmedEmail.startsWith('.') ||
        trimmedEmail.endsWith('.') ||
        trimmedEmail.split('@')[0].endsWith('.')) {
      throw ArgumentError('Invalid email format');
    }

    return Email._(trimmedEmail.toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class Password {
  final String value;

  const Password._(this.value);

  factory Password.create(String password) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters long');
    }

    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      throw ArgumentError(
        'Password must contain at least one letter and one number',
      );
    }

    return Password._(password);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Password && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '*' * value.length; // Hide password in logs
}

class Name {
  final String value;

  const Name._(this.value);

  factory Name.create(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }

    if (trimmedName.length < 2) {
      throw ArgumentError('Name must be at least 2 characters long');
    }

    if (trimmedName.length > 50) {
      throw ArgumentError('Name cannot exceed 50 characters');
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes, unicode letters)
    final nameRegex = RegExp(r"^[\p{L}\s\-']+$", unicode: true);
    if (!nameRegex.hasMatch(trimmedName)) {
      throw ArgumentError('Name contains invalid characters');
    }

    return Name._(trimmedName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Name && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
