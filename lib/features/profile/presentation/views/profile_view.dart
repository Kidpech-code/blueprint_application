import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../domain/entities/profile_entities.dart';
import '../../../common/presentation/widgets/common_widgets.dart';
import '../../../../core/utils.dart';

class ProfileView extends StatefulWidget {
  final String userId;
  final String? tab;

  const ProfileView({super.key, required this.userId, this.tab});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileViewModel _profileViewModel;

  final List<String> _tabs = ['Posts', 'About', 'Photos', 'Friends'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _profileViewModel = context.read<ProfileViewModel>();

    // Set initial tab if provided
    if (widget.tab != null) {
      final tabIndex = _tabs.indexWhere((tab) => tab.toLowerCase() == widget.tab!.toLowerCase());
      if (tabIndex >= 0) {
        _tabController.index = tabIndex;
      }
    }

    // Load profile data
    _profileViewModel.loadProfile(widget.userId, tab: widget.tab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('Error loading profile', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(text: 'Retry', onPressed: () => viewModel.loadProfile(widget.userId), icon: Icons.refresh),
                ],
              ),
            );
          }

          if (!viewModel.hasData) {
            return const EmptyStateWidget(
              title: 'Profile not found',
              subtitle: 'The profile you are looking for does not exist.',
              icon: Icons.person_off,
            );
          }

          return _buildProfileContent(viewModel);
        },
      ),
    );
  }

  Widget _buildProfileContent(ProfileViewModel viewModel) {
    final profile = viewModel.profile!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(background: _buildProfileHeader(profile)),
          ),
          SliverPersistentHeader(
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [_buildPostsTab(profile), _buildAboutTab(profile), _buildPhotosTab(profile), _buildFriendsTab(profile)],
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile) {
    return Stack(
      children: [
        // Cover Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
          child: profile.coverImage != null
              ? Image.network(profile.coverImage!, fit: BoxFit.cover)
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                    ),
                  ),
                ),
        ),

        // Profile Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 47,
                    backgroundImage: profile.profileImage != null ? NetworkImage(profile.profileImage!) : null,
                    child: profile.profileImage == null
                        ? Text(
                            profile.firstName[0].toUpperCase() + profile.lastName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (profile.bio != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.bio!,
                          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (profile.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.white.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(profile.location!, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement follow/unfollow
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Follow'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement message
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab(Profile profile) {
    return const Center(
      child: EmptyStateWidget(title: 'No posts yet', subtitle: 'Posts will appear here when available.', icon: Icons.post_add),
    );
  }

  Widget _buildAboutTab(Profile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              if (profile.bio != null) ...[_buildInfoRow(Icons.info_outline, 'Bio', profile.bio!), const SizedBox(height: 12)],

              _buildInfoRow(Icons.cake, 'Birthday', AppUtils.formatDate(profile.dateOfBirth)),

              if (profile.phone != null) ...[const SizedBox(height: 12), _buildInfoRow(Icons.phone, 'Phone', profile.phone!)],

              if (profile.website != null) ...[const SizedBox(height: 12), _buildInfoRow(Icons.language, 'Website', profile.website!)],

              const SizedBox(height: 12),
              _buildInfoRow(Icons.calendar_today, 'Joined', AppUtils.formatDate(profile.createdAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab(Profile profile) {
    return const Center(
      child: EmptyStateWidget(title: 'No photos yet', subtitle: 'Photos will appear here when available.', icon: Icons.photo_library),
    );
  }

  Widget _buildFriendsTab(Profile profile) {
    return const Center(
      child: EmptyStateWidget(title: 'No friends yet', subtitle: 'Friends will appear here when available.', icon: Icons.people),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
