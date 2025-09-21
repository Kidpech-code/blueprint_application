import '../../domain/repositories/blog_repository.dart';
import '../../domain/entities/blog_entities.dart';
import '../../../../core/error_handling.dart';

class GetBlogPostsUseCase {
  final BlogRepository repository;

  GetBlogPostsUseCase(this.repository);

  Future<Result<List<BlogPost>>> call({
    int page = 1,
    int limit = 10,
    String? category,
    String? tag,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await repository.getPosts(page: page, limit: limit, category: category, tag: tag, search: search, sortBy: sortBy, sortOrder: sortOrder);
  }
}
