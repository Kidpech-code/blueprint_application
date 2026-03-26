import 'package:dio/dio.dart';
import '../models/blog_models.dart';
import '../../../../core/error_handling.dart';
import '../../../../core/dio_error_handler.dart';

abstract class BlogRemoteDataSource {
  Future<BlogPostsResponse> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<BlogPostModel> getPostByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  });

  Future<BlogPostModel> getPostById(String postId);
  Future<List<BlogPostModel>> getFeaturedPosts({int limit = 5});
  Future<List<BlogPostModel>> getRelatedPosts(String postId, {int limit = 5});
  Future<List<BlogCategoryModel>> getCategories();
  Future<BlogPostsResponse> getPostsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 10,
  });
  Future<BlogPostsResponse> getPostsByTag(
    String tag, {
    int page = 1,
    int limit = 10,
  });
  Future<List<BlogCommentModel>> getPostComments(String postId);
  Future<void> togglePostLike(String postId, String accessToken);
  Future<BlogCommentModel> addComment(
    String postId,
    String content,
    String accessToken, {
    String? parentId,
  });
  Future<BlogPostsResponse> searchPosts(
    String query, {
    int page = 1,
    int limit = 10,
  });
}

class BlogRemoteDataSourceImpl
    with DioErrorHandler
    implements BlogRemoteDataSource {
  final Dio dio;

  BlogRemoteDataSourceImpl(this.dio);

  @override
  Future<BlogPostsResponse> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

      if (category != null) queryParameters['category'] = category;
      if (tag != null) queryParameters['tag'] = tag;
      if (search != null) queryParameters['search'] = search;
      if (sortBy != null) queryParameters['sort_by'] = sortBy;
      if (sortOrder != null) queryParameters['sort_order'] = sortOrder;

      final response = await dio.get(
        '/blog/posts',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return BlogPostsResponse.fromJson(response.data);
      } else {
        throw ServerError(
          'Failed to get blog posts',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Blog posts not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting blog posts: $e');
    }
  }

  @override
  Future<BlogPostModel> getPostByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (isPreview) queryParameters['preview'] = 'true';

      final response = await dio.get(
        '/blog/$year/$month/$day/$slug',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.statusCode == 200) {
        return BlogPostModel.fromJson(response.data);
      } else {
        throw ServerError('Blog post not found', response.statusCode ?? 404);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Blog post not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting blog post: $e');
    }
  }

  @override
  Future<BlogPostModel> getPostById(String postId) async {
    try {
      final response = await dio.get('/blog/posts/$postId');

      if (response.statusCode == 200) {
        return BlogPostModel.fromJson(response.data);
      } else {
        throw ServerError('Blog post not found', response.statusCode ?? 404);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Blog post not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting blog post: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getFeaturedPosts({int limit = 5}) async {
    try {
      final response = await dio.get(
        '/blog/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => BlogPostModel.fromJson(json)).toList();
      } else {
        throw ServerError(
          'Failed to get featured posts',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting featured posts: $e');
    }
  }

  @override
  Future<List<BlogPostModel>> getRelatedPosts(
    String postId, {
    int limit = 5,
  }) async {
    try {
      final response = await dio.get(
        '/blog/posts/$postId/related',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => BlogPostModel.fromJson(json)).toList();
      } else {
        throw ServerError(
          'Failed to get related posts',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting related posts: $e');
    }
  }

  @override
  Future<List<BlogCategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/blog/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => BlogCategoryModel.fromJson(json)).toList();
      } else {
        throw ServerError(
          'Failed to get categories',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting categories: $e');
    }
  }

  @override
  Future<BlogPostsResponse> getPostsByCategory(
    String categorySlug, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/blog/categories/$categorySlug/posts',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return BlogPostsResponse.fromJson(response.data);
      } else {
        throw ServerError(
          'Failed to get posts by category',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting posts by category: $e');
    }
  }

  @override
  Future<BlogPostsResponse> getPostsByTag(
    String tag, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/blog/tags/$tag/posts',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return BlogPostsResponse.fromJson(response.data);
      } else {
        throw ServerError(
          'Failed to get posts by tag',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting posts by tag: $e');
    }
  }

  @override
  Future<List<BlogCommentModel>> getPostComments(String postId) async {
    try {
      final response = await dio.get('/blog/posts/$postId/comments');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => BlogCommentModel.fromJson(json)).toList();
      } else {
        throw ServerError('Failed to get comments', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error getting comments: $e');
    }
  }

  @override
  Future<void> togglePostLike(String postId, String accessToken) async {
    try {
      final response = await dio.post(
        '/blog/posts/$postId/like',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw ServerError('Failed to toggle like', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error toggling like: $e');
    }
  }

  @override
  Future<BlogCommentModel> addComment(
    String postId,
    String content,
    String accessToken, {
    String? parentId,
  }) async {
    try {
      final data = <String, dynamic>{'content': content};
      if (parentId != null) data['parent_id'] = parentId;

      final response = await dio.post(
        '/blog/posts/$postId/comments',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 201) {
        return BlogCommentModel.fromJson(response.data);
      } else {
        throw ServerError('Failed to add comment', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error adding comment: $e');
    }
  }

  @override
  Future<BlogPostsResponse> searchPosts(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/blog/search',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return BlogPostsResponse.fromJson(response.data);
      } else {
        throw ServerError('Search failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw handleDioError(e, notFoundMessage: 'Content not found');
    } on AppError {
      rethrow;
    } catch (e) {
      throw UnknownError('Unexpected error searching posts: $e');
    }
  }
}
