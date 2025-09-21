import '../../domain/repositories/blog_repository.dart';
import '../../domain/entities/blog_entities.dart';
import '../datasources/blog_remote_datasource.dart';
import '../../../../core/error_handling.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource remoteDataSource;

  BlogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<BlogPost>>> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await remoteDataSource.getPosts(
        page: page,
        limit: limit,
        category: category,
        tag: tag,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final posts = response.data.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get posts: $e'));
    }
  }

  @override
  Future<Result<BlogPost>> getPostByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  }) async {
    try {
      final model = await remoteDataSource.getPostByDateAndSlug(
        year: year,
        month: month,
        day: day,
        slug: slug,
        isPreview: isPreview,
      );

      return Success(model.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get post: $e'));
    }
  }

  @override
  Future<Result<BlogPost>> getPostById(String postId) async {
    try {
      final model = await remoteDataSource.getPostById(postId);
      return Success(model.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get post: $e'));
    }
  }

  @override
  Future<Result<List<BlogPost>>> getFeaturedPosts({int limit = 5}) async {
    try {
      final models = await remoteDataSource.getFeaturedPosts(limit: limit);
      final posts = models.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get featured posts: $e'));
    }
  }

  @override
  Future<Result<List<BlogPost>>> getRelatedPosts(
    String postId, {
    int limit = 5,
  }) async {
    try {
      final models = await remoteDataSource.getRelatedPosts(
        postId,
        limit: limit,
      );
      final posts = models.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get related posts: $e'));
    }
  }

  @override
  Future<Result<List<BlogCategory>>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      final categories = models.map((model) => model.toEntity()).toList();
      return Success(categories);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get categories: $e'));
    }
  }

  @override
  Future<Result<List<BlogPost>>> getPostsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.getPostsByCategory(
        categorySlug,
        page: page,
        limit: limit,
      );

      final posts = response.data.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get posts by category: $e'));
    }
  }

  @override
  Future<Result<List<BlogPost>>> getPostsByTag(
    String tag, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.getPostsByTag(
        tag,
        page: page,
        limit: limit,
      );

      final posts = response.data.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get posts by tag: $e'));
    }
  }

  @override
  Future<Result<List<BlogComment>>> getPostComments(String postId) async {
    try {
      final models = await remoteDataSource.getPostComments(postId);
      final comments = models.map((model) => model.toEntity()).toList();
      return Success(comments);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to get comments: $e'));
    }
  }

  @override
  Future<Result<void>> togglePostLike(String postId) async {
    try {
      // Note: In a real implementation, you would get the access token from auth repository
      const accessToken = 'dummy_token'; // This should come from AuthRepository
      await remoteDataSource.togglePostLike(postId, accessToken);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to toggle like: $e'));
    }
  }

  @override
  Future<Result<BlogComment>> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    try {
      // Note: In a real implementation, you would get the access token from auth repository
      const accessToken = 'dummy_token'; // This should come from AuthRepository
      final model = await remoteDataSource.addComment(
        postId,
        content,
        accessToken,
        parentId: parentId,
      );

      return Success(model.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to add comment: $e'));
    }
  }

  @override
  Future<Result<List<BlogPost>>> searchPosts(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await remoteDataSource.searchPosts(
        query,
        page: page,
        limit: limit,
      );

      final posts = response.data.map((model) => model.toEntity()).toList();
      return Success(posts);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError('Failed to search posts: $e'));
    }
  }
}
