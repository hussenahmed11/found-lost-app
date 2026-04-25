import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/saved_posts_service.dart';
import '../../widgets/app_button.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Post post;

  const ItemDetailsScreen({super.key, required this.post});

  void _handleContact(BuildContext context) async {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (currentUserId == null) return;
    
    if (currentUserId == post.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself.')),
      );
      return;
    }

    try {
      final chatId = await ChatService().createOrGetChat(currentUserId, post.userId);
      if (context.mounted) {
        Navigator.of(context).pushNamed(
          '/chat-room',
          arguments: {'chatId': chatId, 'otherUserId': post.userId},
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e')),
        );
      }
    }
  }

  void _handleShare() {
    Share.share(
      'Check out this ${widget.post.type} item: ${widget.post.title} at ${widget.post.location}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.post.type == 'lost';
    final posterName = _posterProfile?['name'] ?? 'Loading...';
    final posterImage = _posterProfile?['profileImage'];
    final posterDate = _posterProfile?['createdAt'];

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
                          child: widget.post.imageUrl != null
                              ? Image.network(widget.post.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, a) => Container(
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
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 20,
                          child: _circleButton(
                            icon: Icons.chevron_left,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // Actions row
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 20,
                          child: Row(
                            children: [
                              _circleButton(
                                icon: _isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                onTap: _toggleSave,
                              ),
                              const SizedBox(width: 8),
                              _circleButton(
                                icon: Icons.share,
                                onTap: _handleShare,
                              ),
                            ],
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
                              widget.post.type.toUpperCase(),
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
                                  widget.post.title,
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
                                      widget.post.category,
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
                                  Icons.location_on, widget.post.location),
                              _statChip(Icons.calendar_today,
                                  DateFormat.yMMMd().format(widget.post.createdAt)),
                            ],
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.l),
                            child: Divider(
                                color: AppColors.border.withOpacity(0.5),
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
                            widget.post.description.isNotEmpty
                                ? widget.post.description
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
                                color: AppColors.border.withOpacity(0.5),
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
                                // Avatar
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.round),
                                  ),
                                  child: posterImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.round),
                                          child: Image.network(
                                            posterImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person,
                                                    size: 24,
                                                    color: AppColors
                                                        .textSecondary),
                                          ),
                                        )
                                      : const Icon(Icons.person,
                                          size: 24,
                                          color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      posterName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (posterDate != null)
                                      Text(
                                        'Member since ${posterDate.toString().substring(0, 10)}',
                                        style: const TextStyle(
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
            padding: EdgeInsets.only(
              left: AppSpacing.l,
              right: AppSpacing.l,
              top: AppSpacing.m,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.m,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: AppButton(
              title: 'Contact Owner',
              onPress: _handleContact,
              loading: _contactLoading,
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
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
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
