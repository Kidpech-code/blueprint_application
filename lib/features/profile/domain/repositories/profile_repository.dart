import '../entities/profile_entities.dart';
import '../../../../core/error_handling.dart';

abstract class ProfileRepository {
  /// Get profile by user ID
  Future<Result<Profile>> getProfile(String userId);

  /// Update profile
  Future<Result<Profile>> updateProfile(Profile profile);

  /// Get profile statistics
  Future<Result<ProfileStats>> getProfileStats(String userId);

  /// Upload profile image
  Future<Result<String>> uploadProfileImage(String userId, String imagePath);

  /// Upload cover image
  Future<Result<String>> uploadCoverImage(String userId, String imagePath);

  /// Follow user
  Future<Result<void>> followUser(String userId);

  /// Unfollow user
  Future<Result<void>> unfollowUser(String userId);

  /// Check if user is following another user
  Future<Result<bool>> isFollowing(String userId);

  /// Get followers list
  Future<Result<List<Profile>>> getFollowers(String userId, {int page = 1, int limit = 20});

  /// Get following list
  Future<Result<List<Profile>>> getFollowing(String userId, {int page = 1, int limit = 20});
}
