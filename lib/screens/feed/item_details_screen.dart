import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../widgets/app_button.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Post post;

  const ItemDetailsScreen({super.key, required this.post});

  void _handleContact(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat system will be initialized with the owner.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare() {
    Share.share(
      'Check out this ${post.type} item: ${post.title} at ${post.location}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = post.type == 'lost';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image with overlaid controls
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Hero image
                        Positioned.fill(
                          child: post.imageUrl != null
                              ? Image.network(post.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, _a) => Container(
                                      color: AppColors.border,
                                      child: const Icon(Icons.image,
                                          size: 60,
                                          color: AppColors.textSecondary)))
                              : Container(
                                  color: AppColors.border,
                                  child: const Icon(Icons.image,
                                      size: 60,
                                      color: AppColors.textSecondary)),
                        ),
                        // Back button
                        Positioned(
                          top: 50,
                          left: 20,
                          child: _circleButton(
                            icon: Icons.chevron_left,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // Share button
                        Positioned(
                          top: 50,
                          right: 20,
                          child: _circleButton(
                            icon: Icons.share,
                            onTap: _handleShare,
                          ),
                        ),
                        // Type badge
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.m, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLost
                                  ? AppColors.danger
                                  : AppColors.secondary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.round),
                            ),
                            child: Text(
                              post.type.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content area with rounded top
                  Transform.translate(
                    offset: const Offset(0, -AppRadius.xl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.xl),
                          topRight: Radius.circular(AppRadius.xl),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBF5FF),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.s),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.tag,
                                        size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.m),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statChip(
                                  Icons.location_on, post.location),
                              _statChip(Icons.calendar_today,
                                  DateFormat.yMMMd().format(post.createdAt)),
                            ],
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.l),
                            child: Divider(
                                color: AppColors.border.withValues(alpha: 0.5),
                                height: 1),
                          ),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            post.description.isNotEmpty
                                ? post.description
                                : 'No description provided.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.l),
                            child: Divider(
                                color: AppColors.border.withValues(alpha: 0.5),
                                height: 1),
                          ),

                          // Owner info
                          const Text(
                            'Posted by',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.m),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.round),
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 24,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Member since April 2024',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer with contact button
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: AppButton(
              title: 'Contact Owner',
              onPress: () => _handleContact(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
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
