import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile_entities.dart';

part 'profile_models.g.dart';

@JsonSerializable()
class ProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? bio;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;
  final String? phone;
  final String? website;
  final String? location;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      profileImage: profileImage,
      coverImage: coverImage,
      dateOfBirth: DateTime.parse(dateOfBirth),
      phone: phone,
      website: website,
      location: location,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      bio: profile.bio,
      profileImage: profile.profileImage,
      coverImage: profile.coverImage,
      dateOfBirth: profile.dateOfBirth.toIso8601String(),
      phone: profile.phone,
      website: profile.website,
      location: profile.location,
      createdAt: profile.createdAt.toIso8601String(),
      updatedAt: profile.updatedAt.toIso8601String(),
    );
  }
}

@JsonSerializable()
class ProfileStatsModel {
  final int followers;
  final int following;
  final int posts;
  final int likes;

  const ProfileStatsModel({
    required this.followers,
    required this.following,
    required this.posts,
    required this.likes,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileStatsModelToJson(this);

  ProfileStats toEntity() {
    return ProfileStats(
      followers: followers,
      following: following,
      posts: posts,
      likes: likes,
    );
  }
}

@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? bio;
  @JsonKey(name: 'date_of_birth')
  final String dateOfBirth;
  final String? phone;
  final String? website;
  final String? location;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.bio,
    required this.dateOfBirth,
    this.phone,
    this.website,
    this.location,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
