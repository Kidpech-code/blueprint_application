import 'package:dio/dio.dart';
import '../models/profile_models.dart';
import '../../../../core/error_handling.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> updateProfile(
    String userId,
    UpdateProfileRequest request,
  );
  Future<ProfileStatsModel> getProfileStats(String userId);
  Future<String> uploadProfileImage(String userId, String imagePath);
  Future<String> uploadCoverImage(String userId, String imagePath);
  Future<void> followUser(String userId, String accessToken);
  Future<void> unfollowUser(String userId, String accessToken);
  Future<bool> isFollowing(String userId, String accessToken);
  Future<List<ProfileModel>> getFollowers(String userId, int page, int limit);
  Future<List<ProfileModel>> getFollowing(String userId, int page, int limit);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await dio.get('/profiles/$userId');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerError('Failed to get profile', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error getting profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    try {
      final response = await dio.put(
        '/profiles/$userId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerError(
          'Failed to update profile',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error updating profile: $e');
    }
  }

  @override
  Future<ProfileStatsModel> getProfileStats(String userId) async {
    try {
      final response = await dio.get('/profiles/$userId/stats');

      if (response.statusCode == 200) {
        return ProfileStatsModel.fromJson(response.data);
      } else {
        throw ServerError(
          'Failed to get profile stats',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error getting profile stats: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await dio.post(
        '/profiles/$userId/profile-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['image_url'] as String;
      } else {
        throw ServerError(
          'Failed to upload profile image',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error uploading profile image: $e');
    }
  }

  @override
  Future<String> uploadCoverImage(String userId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await dio.post(
        '/profiles/$userId/cover-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['image_url'] as String;
      } else {
        throw ServerError(
          'Failed to upload cover image',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error uploading cover image: $e');
    }
  }

  @override
  Future<void> followUser(String userId, String accessToken) async {
    try {
      final response = await dio.post(
        '/profiles/$userId/follow',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw ServerError('Failed to follow user', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error following user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String userId, String accessToken) async {
    try {
      final response = await dio.delete(
        '/profiles/$userId/follow',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw ServerError(
          'Failed to unfollow user',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error unfollowing user: $e');
    }
  }

  @override
  Future<bool> isFollowing(String userId, String accessToken) async {
    try {
      final response = await dio.get(
        '/profiles/$userId/is-following',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data['is_following'] as bool;
      } else {
        throw ServerError(
          'Failed to check follow status',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error checking follow status: $e');
    }
  }

  @override
  Future<List<ProfileModel>> getFollowers(
    String userId,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        '/profiles/$userId/followers',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => ProfileModel.fromJson(json)).toList();
      } else {
        throw ServerError(
          'Failed to get followers',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error getting followers: $e');
    }
  }

  @override
  Future<List<ProfileModel>> getFollowing(
    String userId,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        '/profiles/$userId/following',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => ProfileModel.fromJson(json)).toList();
      } else {
        throw ServerError(
          'Failed to get following',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error getting following: $e');
    }
  }

  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutError('Request timed out');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';

        if (statusCode == 401) {
          return AuthenticationError(message);
        } else if (statusCode == 403) {
          return AuthorizationError(message);
        } else if (statusCode == 404) {
          return BusinessLogicError('Profile not found');
        } else {
          return ServerError(message, statusCode ?? 500);
        }

      case DioExceptionType.connectionError:
        return const NetworkError('No internet connection');

      default:
        return UnknownError('Network error: ${error.message}');
    }
  }
}
