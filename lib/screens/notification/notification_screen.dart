import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (notifs.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllRead();
              },
              child: const Text('Tandai Semua'),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Tidak ada notifikasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                return Dismissible(
                  key: Key(notif.id),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    color: notif.isRead ? null : AppColors.primaryLight,
                    child: ListTile(
                      leading: Icon(
                        _getIconForType(notif.type),
                        color: _getColorForType(notif.type),
                      ),
                      title: Text(notif.title),
                      subtitle: Text(notif.body),
                      trailing: notif.isRead
                          ? null
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusCircle),
                              ),
                            ),
                      onTap: () {
                        ref
                            .read(notificationProvider.notifier)
                            .markAsRead(notif.id);
                        if (notif.ticketId != null) {
                          context.push('/tickets/${notif.ticketId}');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForType(NotifType notif) {
    switch (notif) {
      case NotifType.ticketCreated:
        return Icons.add_circle_outline;
      case NotifType.statusUpdated:
        return Icons.update;
      case NotifType.newReply:
        return Icons.reply;
      case NotifType.ticketAssigned:
        return Icons.assignment_ind;
    }
  }

  Color _getColorForType(NotifType notif) {
    switch (notif) {
      case NotifType.ticketCreated:
        return AppColors.statusResolved;
      case NotifType.statusUpdated:
        return AppColors.statusInProgress;
      case NotifType.newReply:
        return AppColors.primary;
      case NotifType.ticketAssigned:
        return AppColors.secondary;
    }
  }
}
