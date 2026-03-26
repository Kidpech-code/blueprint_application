import '../../domain/repositories/blog_repository.dart';
import '../../domain/entities/blog_entities.dart';
import '../../../../core/error_handling.dart';

class GetBlogPostUseCase {
  final BlogRepository repository;

  GetBlogPostUseCase(this.repository);

  Future<Result<BlogPost>> callByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  }) async {
    return await repository.getPostByDateAndSlug(
      year: year,
      month: month,
      day: day,
      slug: slug,
      isPreview: isPreview,
    );
  }

  Future<Result<BlogPost>> callById(String postId) async {
    return await repository.getPostById(postId);
  }
}
