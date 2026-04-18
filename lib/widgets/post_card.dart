import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLost = post.type == 'lost';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m, vertical: AppSpacing.s),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.l),
        elevation: 4,
        shadowColor: AppColors.shadow.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.l),
          child: SizedBox(
            height: 120,
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.l),
                    bottomLeft: Radius.circular(AppRadius.l),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: post.imageUrl != null
                        ? Image.network(
                            post.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, _a) => Container(
                              color: AppColors.border,
                              child: const Icon(Icons.image,
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : Container(
                            color: AppColors.border,
                            child: const Icon(Icons.image,
                                color: AppColors.textSecondary, size: 40),
                          ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header row: badge + category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLost
                                    ? AppColors.danger
                                    : AppColors.secondary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.s),
                              ),
                              child: Text(
                                post.type.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              post.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Title
                        Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        // Footer info rows
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    post.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.yMMMd().format(post.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
