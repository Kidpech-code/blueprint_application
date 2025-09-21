import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/blog_viewmodel.dart';
import '../../domain/entities/blog_entities.dart';
import '../../../common/presentation/widgets/common_widgets.dart';
import '../../../../core/utils.dart';
import '../../../../core/route_manager.dart';

class BlogListView extends StatefulWidget {
  const BlogListView({super.key});

  @override
  State<BlogListView> createState() => _BlogListViewState();
}

class _BlogListViewState extends State<BlogListView> {
  late BlogViewModel _blogViewModel;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _blogViewModel = context.read<BlogViewModel>();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    _blogViewModel.loadPosts(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _blogViewModel.loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<BlogViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingPosts && viewModel.posts.isEmpty) {
            return const LoadingWidget(message: 'Loading posts...');
          }

          if (viewModel.postsError != null && viewModel.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('Error loading posts', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.postsError!.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(text: 'Retry', onPressed: _loadPosts, icon: Icons.refresh),
                ],
              ),
            );
          }

          if (viewModel.posts.isEmpty) {
            return const EmptyStateWidget(
              title: 'No posts found',
              subtitle: 'There are no blog posts available at the moment.',
              icon: Icons.article_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadPosts(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: viewModel.posts.length + (viewModel.hasMorePosts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.posts.length) {
                  return const Padding(padding: EdgeInsets.all(16), child: LoadingWidget());
                }

                final post = viewModel.posts[index];
                return _buildPostCard(post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BlogPost post) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onTap: () {
        final publishedDate = post.publishedAt;
        AppRouter.goToBlogPost(
          year: publishedDate.year.toString(),
          month: publishedDate.month.toString().padLeft(2, '0'),
          day: publishedDate.day.toString().padLeft(2, '0'),
          slug: post.slug,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Image
          if (post.featuredImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.featuredImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Title
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Excerpt
          Text(
            post.excerpt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Metadata
          Row(
            children: [
              CircleAvatar(radius: 12, child: Text(post.authorName[0].toUpperCase(), style: const TextStyle(fontSize: 12))),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(AppUtils.formatDate(post.publishedAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(AppUtils.formatNumber(post.viewCount), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(AppUtils.formatNumber(post.likeCount), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ],
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(tag, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontSize: 11)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
