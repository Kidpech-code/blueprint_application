import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/blog_viewmodel.dart';
import '../../domain/entities/blog_entities.dart';
import '../../../common/presentation/widgets/common_widgets.dart';
import '../../../../core/utils.dart';
import '../../../../core/route_manager.dart';

class BlogDetailView extends StatefulWidget {
  final String year;
  final String month;
  final String day;
  final String slug;
  final bool isPreview;

  const BlogDetailView({
    super.key,
    required this.year,
    required this.month,
    required this.day,
    required this.slug,
    this.isPreview = false,
  });

  @override
  State<BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView> {
  late BlogViewModel _blogViewModel;

  @override
  void initState() {
    super.initState();
    _blogViewModel = context.read<BlogViewModel>();
    _loadPost();
  }

  void _loadPost() {
    _blogViewModel.loadPostByDateAndSlug(
      year: widget.year,
      month: widget.month,
      day: widget.day,
      slug: widget.slug,
      isPreview: widget.isPreview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BlogViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingPost) {
            return const LoadingWidget(message: 'Loading post...');
          }

          if (viewModel.postError != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Post not found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.postError!.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Retry',
                      onPressed: _loadPost,
                      icon: Icons.refresh,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Back to Blog',
                      onPressed: () => AppRouter.goToBlogList(),
                      isOutlined: true,
                      icon: Icons.arrow_back,
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.currentPost == null) {
            return const Scaffold(
              body: EmptyStateWidget(
                title: 'Post not found',
                subtitle: 'The post you are looking for does not exist.',
                icon: Icons.article_outlined,
              ),
            );
          }

          return _buildPostContent(viewModel.currentPost!);
        },
      ),
    );
  }

  Widget _buildPostContent(BlogPost post) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (post.featuredImage != null)
                  Image.network(post.featuredImage!, fit: BoxFit.cover)
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Post metadata
              _buildPostMetadata(post),
              const SizedBox(height: 24),

              // Post content
              _buildPostContentText(post),
              const SizedBox(height: 32),

              // Post tags
              if (post.tags.isNotEmpty) ...[
                _buildPostTags(post),
                const SizedBox(height: 32),
              ],

              // Post actions
              _buildPostActions(post),
              const SizedBox(height: 32),

              // Related posts placeholder
              _buildRelatedPosts(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPostMetadata(BlogPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          child: Text(
            post.authorName[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                AppUtils.formatDate(post.publishedAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              AppUtils.formatNumber(post.viewCount),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              AppUtils.formatNumber(post.likeCount),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostContentText(BlogPost post) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTags(BlogPost post) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostActions(BlogPost post) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.thumb_up_outlined,
            label: 'Like',
            count: post.likeCount,
            onTap: () {
              // TODO: Implement like functionality
            },
          ),
          _buildActionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            count: post.commentCount,
            onTap: () {
              // TODO: Implement comment functionality
            },
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            if (count != null) ...[
              const SizedBox(height: 2),
              Text(
                AppUtils.formatNumber(count),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedPosts() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Posts',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const EmptyStateWidget(
            title: 'No related posts',
            subtitle: 'Related posts will appear here.',
            icon: Icons.article_outlined,
          ),
        ],
      ),
    );
  }
}
