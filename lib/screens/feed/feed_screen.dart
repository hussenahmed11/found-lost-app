import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../../services/saved_posts_service.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final SavedPostsService _savedService = SavedPostsService();
  String? _filterType; // null = all, 'lost', 'found'

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m, vertical: AppSpacing.s),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Lost', 'lost'),
                const SizedBox(width: 8),
                _buildFilterChip('Found', 'found'),
              ],
            ),
          ),
          // Posts list
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _postService.getPosts(type: _filterType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.danger),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'Error loading posts:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: AppSpacing.m),
                          const Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          const Text(
                            'Be the first to report a lost or found item!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    // StreamBuilder auto-refreshes, but we add a small delay for UX
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: _buildPostsList(posts, user?.uid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts, String? currentUserId) {
    if (currentUserId == null) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: posts[index],
            onTap: () => _navigateToDetails(posts[index]),
          );
        },
      );
    }

    return StreamBuilder<List<String>>(
      stream: _savedService.getSavedPostIds(currentUserId),
      builder: (context, savedSnapshot) {
        final savedIds = savedSnapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              post: post,
              isSaved: savedIds.contains(post.id),
              onTap: () => _navigateToDetails(post),
              onSave: () => _savedService.toggleSaved(currentUserId, post.id),
            );
          },
        );
      },
    );
  }

  void _navigateToDetails(Post post) {
    Navigator.of(context).pushNamed('/item-details', arguments: post);
  }

  Widget _buildFilterChip(String label, String? type) {
    final isActive = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.round),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
