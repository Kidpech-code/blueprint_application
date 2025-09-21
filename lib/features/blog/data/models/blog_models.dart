import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/blog_entities.dart';

part 'blog_models.g.dart';

@JsonSerializable()
class BlogPostModel {
  final String id;
  final String slug;
  final String title;
  final String content;
  final String excerpt;
  @JsonKey(name: 'featured_image')
  final String? featuredImage;
  @JsonKey(name: 'author_id')
  final String authorId;
  @JsonKey(name: 'author_name')
  final String authorName;
  final List<String> tags;
  @JsonKey(name: 'published_at')
  final String publishedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'comment_count')
  final int commentCount;

  const BlogPostModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.content,
    required this.excerpt,
    this.featuredImage,
    required this.authorId,
    required this.authorName,
    required this.tags,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) => _$BlogPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlogPostModelToJson(this);

  BlogPost toEntity() {
    return BlogPost(
      id: id,
      slug: slug,
      title: title,
      content: content,
      excerpt: excerpt,
      featuredImage: featuredImage,
      authorId: authorId,
      authorName: authorName,
      tags: tags,
      publishedAt: DateTime.parse(publishedAt),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isPublished: isPublished,
      isFeatured: isFeatured,
      viewCount: viewCount,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}

@JsonSerializable()
class BlogCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  @JsonKey(name: 'post_count')
  final int postCount;

  const BlogCategoryModel({required this.id, required this.name, required this.slug, this.description, required this.postCount});

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) => _$BlogCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlogCategoryModelToJson(this);

  BlogCategory toEntity() {
    return BlogCategory(id: id, name: name, slug: slug, description: description, postCount: postCount);
  }
}

@JsonSerializable()
class BlogCommentModel {
  final String id;
  @JsonKey(name: 'post_id')
  final String postId;
  @JsonKey(name: 'author_id')
  final String authorId;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'author_avatar')
  final String? authorAvatar;
  final String content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  final List<BlogCommentModel> replies;

  const BlogCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.parentId,
    required this.replies,
  });

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) => _$BlogCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlogCommentModelToJson(this);

  BlogComment toEntity() {
    return BlogComment(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      createdAt: DateTime.parse(createdAt),
      parentId: parentId,
      replies: replies.map((reply) => reply.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class BlogPostsResponse {
  final List<BlogPostModel> data;
  final int total;
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'last_page')
  final int lastPage;

  const BlogPostsResponse({required this.data, required this.total, required this.currentPage, required this.perPage, required this.lastPage});

  factory BlogPostsResponse.fromJson(Map<String, dynamic> json) => _$BlogPostsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlogPostsResponseToJson(this);
}
