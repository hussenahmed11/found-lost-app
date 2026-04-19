import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../../services/saved_posts_service.dart';
import '../../widgets/post_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  final SavedPostsService _savedService = SavedPostsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.s),

                    // Avatar
                    GestureDetector(
                      onTap: () => _navigateToEditProfile(context),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.round),
                              boxShadow: AppShadows.medium,
                            ),
                            child: profile?['profileImage'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.round),
                                    child: CachedNetworkImage(
                                      imageUrl: profile!['profileImage'],
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.textSecondary),
                                      errorWidget: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.textSecondary),
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 50,
                                    color: AppColors.textSecondary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.round),
                                border: Border.all(
                                    color: AppColors.surface, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Name
                    Text(
                      profile?['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Email
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Member since
                    if (profile?['createdAt'] != null)
                      Text(
                        'Member since ${profile!['createdAt'].toString().substring(0, 10)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.l),

                    // Stats card with real data
                    if (user != null)
                      StreamBuilder<List<Post>>(
                        stream: _postService.getUserPosts(user.uid),
                        builder: (context, snapshot) {
                          final posts = snapshot.data ?? [];
                          final lostCount = posts
                              .where((p) => p.type == 'lost')
                              .length;
                          final foundCount = posts
                              .where((p) => p.type == 'found')
                              .length;
                          final resolvedCount = posts
                              .where((p) => p.status == 'resolved')
                              .length;

                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.l),
                              boxShadow: AppShadows.light,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                    label: 'Lost',
                                    value: '$lostCount',
                                    color: AppColors.danger),
                                _StatItem(
                                    label: 'Found',
                                    value: '$foundCount',
                                    color: AppColors.secondary),
                                _StatItem(
                                    label: 'Resolved',
                                    value: '$resolvedCount',
                                    color: AppColors.primary),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacing.l),

                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            icon: Icons.edit,
                            label: 'Edit Profile',
                            onTap: () => _navigateToEditProfile(context),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: _actionButton(
                            icon: Icons.logout,
                            label: 'Logout',
                            color: AppColors.danger,
                            onTap: () => _confirmLogout(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.l),
                  ],
                ),
              ),
            ),

            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'My Posts'),
                    Tab(text: 'Saved Posts'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // My Posts tab
            _buildMyPostsTab(user?.uid),
            // Saved Posts tab
            _buildSavedPostsTab(user?.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPostsTab(String? userId) {
    if (userId == null) {
      return const Center(child: Text('Please log in'));
    }

    return StreamBuilder<List<Post>>(
      stream: _postService.getUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.post_add,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.m),
                const Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: AppSpacing.s),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: posts[index],
              onTap: () => Navigator.of(context)
                  .pushNamed('/item-details', arguments: posts[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedPostsTab(String? userId) {
    if (userId == null) {
      return const Center(child: Text('Please log in'));
    }

    return StreamBuilder<List<Post>>(
      stream: _savedService.getSavedPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_outline,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.m),
                const Text(
                  'No saved posts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: AppSpacing.s),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: posts[index],
              isSaved: true,
              onTap: () => Navigator.of(context)
                  .pushNamed('/item-details', arguments: posts[index]),
              onSave: () => _savedService.toggleSaved(userId, posts[index].id),
            );
          },
        );
      },
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.m)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    Color color = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.m),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: AppShadows.light,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Delegate to pin the TabBar header.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
