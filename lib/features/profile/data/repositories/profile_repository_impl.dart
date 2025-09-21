import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entities.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_models.dart';
import '../../../../core/error_handling.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<Profile>> getProfile(String userId) async {
    try {
      final profileModel = await remoteDataSource.getProfile(userId);
      return Success(profileModel.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get profile: $e'));
    }
  }

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
    try {
      final request = UpdateProfileRequest(
        firstName: profile.firstName,
        lastName: profile.lastName,
        bio: profile.bio,
        dateOfBirth: profile.dateOfBirth.toIso8601String(),
        phone: profile.phone,
        website: profile.website,
        location: profile.location,
      );

      final profileModel = await remoteDataSource.updateProfile(
        profile.userId,
        request,
      );
      return Success(profileModel.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to update profile: $e'));
    }
  }

  @override
  Future<Result<ProfileStats>> getProfileStats(String userId) async {
    try {
      final statsModel = await remoteDataSource.getProfileStats(userId);
      return Success(statsModel.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get profile stats: $e'));
    }
  }

  @override
  Future<Result<String>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(
        userId,
        imagePath,
      );
      return Success(imageUrl);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to upload profile image: $e'));
    }
  }

  @override
  Future<Result<String>> uploadCoverImage(
    String userId,
    String imagePath,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadCoverImage(
        userId,
        imagePath,
      );
      return Success(imageUrl);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to upload cover image: $e'));
    }
  }

  @override
  Future<Result<void>> followUser(String userId) async {
    try {
      // Note: In a real implementation, you would get the access token from auth repository
      const accessToken = 'dummy_token'; // This should come from AuthRepository
      await remoteDataSource.followUser(userId, accessToken);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to follow user: $e'));
    }
  }

  @override
  Future<Result<void>> unfollowUser(String userId) async {
    try {
      // Note: In a real implementation, you would get the access token from auth repository
      const accessToken = 'dummy_token'; // This should come from AuthRepository
      await remoteDataSource.unfollowUser(userId, accessToken);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to unfollow user: $e'));
    }
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    try {
      // Note: In a real implementation, you would get the access token from auth repository
      const accessToken = 'dummy_token'; // This should come from AuthRepository
      final isFollowing = await remoteDataSource.isFollowing(
        userId,
        accessToken,
      );
      return Success(isFollowing);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to check follow status: $e'));
    }
  }

  @override
  Future<Result<List<Profile>>> getFollowers(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final profileModels = await remoteDataSource.getFollowers(
        userId,
        page,
        limit,
      );
      final profiles = profileModels.map((model) => model.toEntity()).toList();
      return Success(profiles);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get followers: $e'));
    }
  }

  @override
  Future<Result<List<Profile>>> getFollowing(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final profileModels = await remoteDataSource.getFollowing(
        userId,
        page,
        limit,
      );
      final profiles = profileModels.map((model) => model.toEntity()).toList();
      return Success(profiles);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get following: $e'));
    }
  }
}
