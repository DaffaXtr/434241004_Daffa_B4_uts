import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../main.dart'; // import supabase client
import 'auth_provider.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationState({this.notifications = const [], this.isLoading = false});
}

class NotificationNotifier extends Notifier<NotificationState> {
  
  @override
  NotificationState build() {
    ref.watch(authProvider.select((state) => state.currentUser));
    Future.microtask(() => _loadNotifications());
    return NotificationState(isLoading: true);
  }

  Future<void> _loadNotifications() async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    try {
      final response = await supabase.from('notifications').select().eq('user_id', currentUser.id).order('created_at', ascending: false);
      final notifications = response.map((data) => NotificationModel.fromJson(data)).toList();
      state = NotificationState(notifications: notifications, isLoading: false);
    } catch (e) {
      state = NotificationState(notifications: [], isLoading: false);
    }
  }

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;

  Future<void> markAsRead(String id) async {
    try {
      await supabase.from('notifications').update({'is_read': true}).eq('id', id);

      final index = state.notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updated = state.notifications[index];
        final newNotif = NotificationModel(
          id: updated.id,
          userId: updated.userId,
          title: updated.title,
          body: updated.body,
          type: updated.type,
          ticketId: updated.ticketId,
          isRead: true,
          createdAt: updated.createdAt,
        );
        final newList = List<NotificationModel>.from(state.notifications);
        newList[index] = newNotif;
        state = NotificationState(notifications: newList, isLoading: false);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllRead() async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    try {
      await supabase.from('notifications').update({'is_read': true}).eq('user_id', currentUser.id).eq('is_read', false);

      final newList = state.notifications
          .map((n) => NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                ticketId: n.ticketId,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      state = NotificationState(notifications: newList, isLoading: false);
    } catch (e) {
      // Handle error
    }
  }
}

final NotifierProvider<NotificationNotifier, NotificationState> notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  () => NotificationNotifier(),
);

final Provider<int> unreadCountProvider = Provider<int>((Ref ref) {
  return ref.watch(notificationProvider).notifications.where((n) => !n.isRead).length;
});