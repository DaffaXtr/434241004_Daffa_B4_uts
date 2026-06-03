import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/ticket_provider.dart';
import 'status_badge.dart';

class TicketCard extends ConsumerWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppColors.statusOpen; // Red
      case TicketStatus.inProgress:
        return AppColors.statusInProgress; // Orange
      case TicketStatus.resolved:
        return AppColors.statusResolved; // Green
      case TicketStatus.closed:
        return AppColors.statusClosed; // Blue
    }
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _getStatusColor(ticket.status);
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    // Get dummy avatars
    final allUsers = ref.watch(allUsersProvider);

    final currentUser = ref.watch(authProvider).currentUser;

    final reporter = allUsers.firstWhere(
      (u) => u.id == ticket.reporterId,
      orElse: () => currentUser?.id == ticket.reporterId
          ? currentUser!
          : const UserModel(
              id: 'unknown', name: 'Unknown', email: '', username: '', role: UserRole.user, department: '',
            ),
    );

    final assignee = ticket.assignedToId != null
        ? allUsers.firstWhere(
            (u) => u.id == ticket.assignedToId,
            orElse: () => currentUser?.id == ticket.assignedToId
                ? currentUser!
                : const UserModel(
                    id: 'unknown', name: 'Unknown', email: '', username: '', role: UserRole.user, department: '',
                  ),
          )
        : null;
        
    final commentCount = ref.watch(commentProvider(ticket.id)).comments.length;

    // Build the pill style
    Widget buildPill(String text, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.transparent : color.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.push('/tickets/${ticket.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: baseColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Pills and More Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StatusBadge(status: ticket.status),
                        const SizedBox(width: 8),
                        buildPill(ticket.priorityLabel, _getPriorityColor(ticket.priority)),
                      ],
                    ),
                    Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Title and Description
                Text(
                  ticket.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Bottom Row: Avatars and Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatars
                    Container(
                      height: 32,
                      width: assignee != null ? 52 : 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkContainer : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 2,
                            top: 2,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                reporter.name[0],
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (assignee != null)
                            Positioned(
                              left: 20,
                              top: 2,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.secondary,
                                child: Text(
                                  assignee.name[0],
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Icons and Counts
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          commentCount.toString(),
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.attach_file, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          ticket.attachments.length.toString(),
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
