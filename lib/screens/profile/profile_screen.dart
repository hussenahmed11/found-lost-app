import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/post_card.dart';

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

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    final postService = PostService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: postService.getPosts(), // We filter by userId below to avoid index requirement
          builder: (context, snapshot) {
            final allPosts = snapshot.data ?? [];
            final myPosts = allPosts.where((p) => p.userId == user.uid).toList();
            
            int lostCount = myPosts.where((p) => p.type.toLowerCase() == 'lost' && p.status != 'resolved').length;
            int foundCount = myPosts.where((p) => p.type.toLowerCase() == 'found' && p.status != 'resolved').length;
            int resolvedCount = myPosts.where((p) => p.status == 'resolved').length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadius.round),
                          boxShadow: AppShadows.medium,
                        ),
                        child: const Icon(Icons.person,
                            size: 50, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.s),

                      // Name
                      Text(
                        profile?['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.l),

                      // Stats card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          boxShadow: AppShadows.light,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(label: 'Lost', value: lostCount.toString(), color: AppColors.danger),
                            _StatItem(label: 'Found', value: foundCount.toString(), color: AppColors.secondary),
                            _StatItem(label: 'Resolved', value: resolvedCount.toString(), color: AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Logout button
                      AppButton(
                        title: 'Logout',
                        onPress: () => authProvider.logout(),
                        type: AppButtonType.danger,
                      ),
                    ],
                  ),
                ),
                
                // My Posts Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: myPosts.isEmpty
                      ? const Center(child: Text('No posts yet', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          itemCount: myPosts.length,
                          itemBuilder: (context, index) {
                            final post = myPosts[index];
                            return PostCard(
                              post: post,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/item-details',
                                  arguments: post,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
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
            fontSize: 24,
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
