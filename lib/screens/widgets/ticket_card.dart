import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/ticket_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import 'status_badge.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return AppColors.priorityLow;
      case TicketPriority.medium:
        return AppColors.priorityMedium;
      case TicketPriority.high:
        return AppColors.priorityHigh;
      case TicketPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  Color _getCategoryBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkContainerHigh
        : AppColors.grey200;
  }

  Color _getCategoryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.grey300
        : AppColors.grey700;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }
    return '${diff.inDays ~/ 7} minggu lalu';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tickets/${ticket.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.id,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Title
              Text(
                ticket.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),

              // Description
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.md),

              // Footer: Priority, Category, Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(ticket.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      ticket.priorityLabel,
                      style: TextStyle(
                        color: _getPriorityColor(ticket.priority),
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryBg(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      ticket.categoryLabel,
                      style: TextStyle(
                        color: _getCategoryText(context),
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ),
                  Text(
                    _timeAgo(ticket.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
