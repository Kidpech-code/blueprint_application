// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogPostModel _$BlogPostModelFromJson(Map<String, dynamic> json) =>
    BlogPostModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String,
      featuredImage: json['featured_image'] as String?,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      publishedAt: json['published_at'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      isPublished: json['is_published'] as bool,
      isFeatured: json['is_featured'] as bool,
      viewCount: (json['view_count'] as num).toInt(),
      likeCount: (json['like_count'] as num).toInt(),
      commentCount: (json['comment_count'] as num).toInt(),
    );

Map<String, dynamic> _$BlogPostModelToJson(BlogPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'featured_image': instance.featuredImage,
      'author_id': instance.authorId,
      'author_name': instance.authorName,
      'tags': instance.tags,
      'published_at': instance.publishedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'is_published': instance.isPublished,
      'is_featured': instance.isFeatured,
      'view_count': instance.viewCount,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
    };

BlogCategoryModel _$BlogCategoryModelFromJson(Map<String, dynamic> json) =>
    BlogCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      postCount: (json['post_count'] as num).toInt(),
    );

Map<String, dynamic> _$BlogCategoryModelToJson(BlogCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'post_count': instance.postCount,
    };

BlogCommentModel _$BlogCommentModelFromJson(Map<String, dynamic> json) =>
    BlogCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String?,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      parentId: json['parent_id'] as String?,
      replies: (json['replies'] as List<dynamic>)
          .map((e) => BlogCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BlogCommentModelToJson(BlogCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'author_id': instance.authorId,
      'author_name': instance.authorName,
      'author_avatar': instance.authorAvatar,
      'content': instance.content,
      'created_at': instance.createdAt,
      'parent_id': instance.parentId,
      'replies': instance.replies,
    };

BlogPostsResponse _$BlogPostsResponseFromJson(Map<String, dynamic> json) =>
    BlogPostsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => BlogPostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
    );

Map<String, dynamic> _$BlogPostsResponseToJson(BlogPostsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'last_page': instance.lastPage,
    };
