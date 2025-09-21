import 'package:flutter/foundation.dart';
import '../../application/usecases/get_blog_posts_usecase.dart';
import '../../application/usecases/get_blog_post_usecase.dart';
import '../../domain/entities/blog_entities.dart';
import '../../../../core/error_handling.dart';

enum BlogState { initial, loading, loaded, error }

class BlogViewModel extends ChangeNotifier {
  final GetBlogPostsUseCase getBlogPostsUseCase;
  final GetBlogPostUseCase getBlogPostUseCase;

  BlogViewModel({required this.getBlogPostsUseCase, required this.getBlogPostUseCase});

  // Posts List State
  BlogState _postsState = BlogState.initial;
  List<BlogPost> _posts = [];
  AppError? _postsError;
  int _currentPage = 1;
  bool _hasMorePosts = true;

  // Single Post State
  BlogState _postState = BlogState.initial;
  BlogPost? _currentPost;
  AppError? _postError;

  // Getters for Posts List
  BlogState get postsState => _postsState;
  List<BlogPost> get posts => _posts;
  AppError? get postsError => _postsError;
  bool get isLoadingPosts => _postsState == BlogState.loading;
  bool get hasMorePosts => _hasMorePosts;

  // Getters for Single Post
  BlogState get postState => _postState;
  BlogPost? get currentPost => _currentPost;
  AppError? get postError => _postError;
  bool get isLoadingPost => _postState == BlogState.loading;

  // Load Posts
  Future<void> loadPosts({bool refresh = false, String? category, String? tag, String? search, String? sortBy, String? sortOrder}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _posts.clear();
    }

    _setPostsState(BlogState.loading);

    final result = await getBlogPostsUseCase.call(
      page: _currentPage,
      category: category,
      tag: tag,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    result.fold(
      (newPosts) {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }

        _hasMorePosts = newPosts.length == 10; // Assuming 10 is the limit
        _currentPage++;
        _setPostsState(BlogState.loaded);
      },
      (error) {
        _postsError = error;
        _setPostsState(BlogState.error);
      },
    );
  }

  // Load Single Post by Date and Slug
  Future<void> loadPostByDateAndSlug({
    required String year,
    required String month,
    required String day,
    required String slug,
    bool isPreview = false,
  }) async {
    _setPostState(BlogState.loading);

    final result = await getBlogPostUseCase.callByDateAndSlug(year: year, month: month, day: day, slug: slug, isPreview: isPreview);

    result.fold(
      (post) {
        _currentPost = post;
        _setPostState(BlogState.loaded);
      },
      (error) {
        _postError = error;
        _setPostState(BlogState.error);
      },
    );
  }

  // Load Single Post by ID
  Future<void> loadPostById(String postId) async {
    _setPostState(BlogState.loading);

    final result = await getBlogPostUseCase.callById(postId);

    result.fold(
      (post) {
        _currentPost = post;
        _setPostState(BlogState.loaded);
      },
      (error) {
        _postError = error;
        _setPostState(BlogState.error);
      },
    );
  }

  // Load More Posts
  Future<void> loadMorePosts({String? category, String? tag, String? search, String? sortBy, String? sortOrder}) async {
    if (!_hasMorePosts || _postsState == BlogState.loading) return;

    await loadPosts(refresh: false, category: category, tag: tag, search: search, sortBy: sortBy, sortOrder: sortOrder);
  }

  // Clear Posts Error
  void clearPostsError() {
    _postsError = null;
    notifyListeners();
  }

  // Clear Post Error
  void clearPostError() {
    _postError = null;
    notifyListeners();
  }

  void _setPostsState(BlogState newState) {
    _postsState = newState;
    notifyListeners();
  }

  void _setPostState(BlogState newState) {
    _postState = newState;
    notifyListeners();
  }
}
