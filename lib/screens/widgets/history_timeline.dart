import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/history_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class HistoryTimeline extends ConsumerWidget {
  final List<HistoryModel> histories;

  const HistoryTimeline({super.key, required this.histories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (histories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Text(
          'Belum ada riwayat',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final allUsers = ref.watch(allUsersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        final isLast = index == histories.length - 1;

        final actor = allUsers.firstWhere(
          (u) => u.id == history.actorId,
          orElse: () => const UserModel(
            id: 'unknown',
            name: 'System',
            email: '',
            username: '',
            role: UserRole.user,
            department: '',
          ),
        );

        IconData iconData;
        Color iconColor;
        switch (history.action) {
          case HistoryAction.created:
            iconData = Icons.add_circle;
            iconColor = AppColors.statusOpen;
            break;
          case HistoryAction.statusUpdated:
            if (history.description.contains('Resolved')) {
              iconData = Icons.check_circle_outline;
              iconColor = AppColors.statusResolved;
            } else if (history.description.contains('Closed')) {
              iconData = Icons.cancel_outlined;
              iconColor = AppColors.statusClosed;
            } else if (history.description.contains('In Progress')) {
              iconData = Icons.pending_actions;
              iconColor = AppColors.statusInProgress;
            } else {
              iconData = Icons.update;
              iconColor = AppColors.statusInProgress;
            }
            break;
          case HistoryAction.assigned:
            iconData = Icons.assignment_ind;
            iconColor = AppColors.primary;
            break;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and icon
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, size: 20, color: iconColor),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDark ? AppColors.grey800 : AppColors.grey300,
                        ),
                      ),
                    if (isLast)
                      const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              history.action.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(history.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        history.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh: ${actor.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.grey500 : AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
