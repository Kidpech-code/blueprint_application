import 'package:equatable/equatable.dart';

// User Entity
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({required this.id, required this.email, required this.name, this.profileImage, required this.createdAt, this.lastLoginAt});

  @override
  List<Object?> get props => [id, email, name, profileImage, createdAt, lastLoginAt];

  User copyWith({String? id, String? email, String? name, String? profileImage, DateTime? createdAt, DateTime? lastLoginAt}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

// Auth Token Entity
class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthToken({required this.accessToken, required this.refreshToken, required this.expiresAt});

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt];

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthToken copyWith({String? accessToken, String? refreshToken, DateTime? expiresAt}) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
