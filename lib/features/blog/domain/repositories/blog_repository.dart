import '../entities/blog_entities.dart';
import '../../../../core/error_handling.dart';

abstract class BlogRepository {
  /// Get blog posts with pagination and filters
  Future<Result<List<BlogPost>>> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  /// Get blog post by date and slug
  Future<Result<BlogPost>> getPostByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  });

  /// Get blog post by ID
  Future<Result<BlogPost>> getPostById(String postId);

  /// Get featured posts
  Future<Result<List<BlogPost>>> getFeaturedPosts({int limit = 5});

  /// Get related posts
  Future<Result<List<BlogPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  });

  /// Get blog categories
  Future<Result<List<BlogCategory>>> getCategories();

  /// Get posts by category
  Future<Result<List<BlogPost>>> getPostsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 10,
  });

  /// Get posts by tag
  Future<Result<List<BlogPost>>> getPostsByTag(
    String tag, {
    int page = 1,
    int limit = 10,
  });

  /// Get post comments
  Future<Result<List<BlogComment>>> getPostComments(String postId);

  /// Like/Unlike post
  Future<Result<void>> togglePostLike(String postId);

  /// Add comment to post
  Future<Result<BlogComment>> addComment(
    String postId,
    String content, {
    String? parentId,
  });

  /// Search posts
  Future<Result<List<BlogPost>>> searchPosts(
    String query, {
    int page = 1,
    int limit = 10,
  });
}
