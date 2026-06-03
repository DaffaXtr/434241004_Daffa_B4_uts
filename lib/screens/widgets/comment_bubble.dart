import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class CommentBubble extends ConsumerWidget {
  final CommentModel comment;
  final String currentUserId;
  final bool isStaff;

  const CommentBubble({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.isStaff,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Komentar internal hanya tampil jika isStaff
    if (comment.isInternal && !isStaff) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allUsers = ref.watch(allUsersProvider);
    final author = allUsers.firstWhere(
      (u) => u.id == comment.authorId,
      orElse: () => const UserModel(
        id: 'unknown',
        name: 'Unknown',
        email: '',
        username: '',
        role: UserRole.user,
        department: '',
      ),
    );

    final isCurrentUser = comment.authorId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (comment.isInternal)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.xs),
              child: Text(
                '[INTERNAL]',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.statusOpen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkContainer
                        : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 0),
                  bottomRight: Radius.circular(isCurrentUser ? 0 : 20),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(
                  color: comment.isInternal
                      ? AppColors.statusOpen
                      : (isCurrentUser ? AppColors.primary : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.02))),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isCurrentUser ? Colors.white70 : (isDark ? Colors.white70 : AppColors.grey700),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.xs),
            child: Text(
              _timeAgo(comment.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
