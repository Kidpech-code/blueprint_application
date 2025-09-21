// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  bio: json['bio'] as String?,
  profileImage: json['profile_image'] as String?,
  coverImage: json['cover_image'] as String?,
  dateOfBirth: json['date_of_birth'] as String,
  phone: json['phone'] as String?,
  website: json['website'] as String?,
  location: json['location'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'bio': instance.bio,
      'profile_image': instance.profileImage,
      'cover_image': instance.coverImage,
      'date_of_birth': instance.dateOfBirth,
      'phone': instance.phone,
      'website': instance.website,
      'location': instance.location,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ProfileStatsModel _$ProfileStatsModelFromJson(Map<String, dynamic> json) =>
    ProfileStatsModel(
      followers: (json['followers'] as num).toInt(),
      following: (json['following'] as num).toInt(),
      posts: (json['posts'] as num).toInt(),
      likes: (json['likes'] as num).toInt(),
    );

Map<String, dynamic> _$ProfileStatsModelToJson(ProfileStatsModel instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
      'posts': instance.posts,
      'likes': instance.likes,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  bio: json['bio'] as String?,
  dateOfBirth: json['date_of_birth'] as String,
  phone: json['phone'] as String?,
  website: json['website'] as String?,
  location: json['location'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'bio': instance.bio,
  'date_of_birth': instance.dateOfBirth,
  'phone': instance.phone,
  'website': instance.website,
  'location': instance.location,
};
