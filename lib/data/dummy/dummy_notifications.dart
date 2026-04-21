import '../../models/notification_model.dart';

final dummyNotifications = [
  NotificationModel(
    id: 'n001',
    title: 'Tiket Diperbarui',
    body: 'TKT-002 status berubah menjadi In Progress',
    type: NotifType.statusUpdated,
    ticketId: 'TKT-002',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  NotificationModel(
    id: 'n002',
    title: 'Balasan Baru',
    body: 'Andi Wijaya membalas tiket TKT-002 Anda',
    type: NotifType.newReply,
    ticketId: 'TKT-002',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
  ),
  NotificationModel(
    id: 'n003',
    title: 'Tiket Berhasil Dibuat',
    body: 'TKT-001 berhasil dikirim ke tim helpdesk',
    type: NotifType.ticketCreated,
    ticketId: 'TKT-001',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];
