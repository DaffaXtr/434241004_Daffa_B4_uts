import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy/dummy_notifications.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super(List.from(dummyNotifications));

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = state.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updated = state[index];
      final newNotif = NotificationModel(
        id: updated.id,
        title: updated.title,
        body: updated.body,
        type: updated.type,
        ticketId: updated.ticketId,
        isRead: true,
        createdAt: updated.createdAt,
      );
      final newList = List<NotificationModel>.from(state);
      newList[index] = newNotif;
      state = newList;
    }
  }

  void markAllRead() {
    state = state
        .map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          ticketId: n.ticketId,
          isRead: true,
          createdAt: n.createdAt,
        ))
        .toList();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
