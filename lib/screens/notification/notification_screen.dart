import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }
    return '${diff.inDays ~/ 7}w';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);
    final unreadCount = notifs.where((n) => !n.isRead).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  Text(
                    'Notifikasi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusOpen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unreadCount BARU',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Sub-header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TERBARU',
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: unreadCount > 0
                        ? () => ref.read(notificationProvider.notifier).markAllRead()
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Tandai semua dibaca'),
                  ),
                ],
              ),
            ),
            
            // Notification List
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkContainer : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: isDark ? AppColors.grey600 : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Belum ada notifikasi',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
                      itemCount: notifs.length,
                      itemBuilder: (context, index) {
                        final notif = notifs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              ref.read(notificationProvider.notifier).markAsRead(notif.id);
                              if (notif.ticketId != null) {
                                context.push('/tickets/${notif.ticketId}');
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left Border for Unread
                                    Container(
                                      width: 4,
                                      color: notif.isRead ? Colors.transparent : AppColors.primary,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Icon
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: notif.isRead 
                                                    ? (isDark ? AppColors.darkBg : Colors.grey.shade100)
                                                    : AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                _getIconForType(notif.type),
                                                color: notif.isRead ? AppColors.grey500 : AppColors.primary,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Text Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          notif.title,
                                                          style: TextStyle(
                                                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                                            fontSize: 15,
                                                            color: isDark ? Colors.white : Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        _timeAgo(notif.createdAt),
                                                        style: TextStyle(
                                                          color: notif.isRead ? AppColors.grey500 : AppColors.primary,
                                                          fontSize: 12,
                                                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    notif.body,
                                                    style: TextStyle(
                                                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                                                      fontSize: 13,
                                                      height: 1.4,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(NotifType notif) {
    switch (notif) {
      case NotifType.ticketCreated:
        return Icons.note_add_outlined;
      case NotifType.statusUpdated:
        return Icons.change_circle_outlined;
      case NotifType.newReply:
        return Icons.chat_bubble_outline;
      case NotifType.ticketAssigned:
        return Icons.person_add_alt_1_outlined;
    }
  }
}
