import 'package:equatable/equatable.dart';

// Blog Post Entity
class BlogPost extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String content;
  final String excerpt;
  final String? featuredImage;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final int commentCount;

  const BlogPost({
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

  @override
  List<Object?> get props => [
    id,
    slug,
    title,
    content,
    excerpt,
    featuredImage,
    authorId,
    authorName,
    tags,
    publishedAt,
    createdAt,
    updatedAt,
    isPublished,
    isFeatured,
    viewCount,
    likeCount,
    commentCount,
  ];

  BlogPost copyWith({
    String? id,
    String? slug,
    String? title,
    String? content,
    String? excerpt,
    String? featuredImage,
    String? authorId,
    String? authorName,
    List<String>? tags,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    int? commentCount,
  }) {
    return BlogPost(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      featuredImage: featuredImage ?? this.featuredImage,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}

// Blog Category Entity
class BlogCategory extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int postCount;

  const BlogCategory({required this.id, required this.name, required this.slug, this.description, required this.postCount});

  @override
  List<Object?> get props => [id, name, slug, description, postCount];
}

// Blog Comment Entity
class BlogComment extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final List<BlogComment> replies;

  const BlogComment({
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

  @override
  List<Object?> get props => [id, postId, authorId, authorName, authorAvatar, content, createdAt, parentId, replies];
}
