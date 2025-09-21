import 'package:equatable/equatable.dart';

// Profile Entity
class Profile extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profileImage;
  final String? coverImage;
  final DateTime dateOfBirth;
  final String? phone;
  final String? website;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profileImage,
    this.coverImage,
    required this.dateOfBirth,
    this.phone,
    this.website,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    firstName,
    lastName,
    bio,
    profileImage,
    coverImage,
    dateOfBirth,
    phone,
    website,
    location,
    createdAt,
    updatedAt,
  ];

  String get fullName => '$firstName $lastName';

  Profile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? profileImage,
    String? coverImage,
    DateTime? dateOfBirth,
    String? phone,
    String? website,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Profile Statistics Entity
class ProfileStats extends Equatable {
  final int followers;
  final int following;
  final int posts;
  final int likes;

  const ProfileStats({
    required this.followers,
    required this.following,
    required this.posts,
    required this.likes,
  });

  @override
  List<Object> get props => [followers, following, posts, likes];
}
