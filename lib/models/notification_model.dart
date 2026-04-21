enum NotifType { ticketCreated, statusUpdated, newReply, ticketAssigned }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.ticketId,
    this.isRead = false,
    required this.createdAt,
  });
}
