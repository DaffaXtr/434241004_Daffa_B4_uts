enum NotifType { ticketCreated, statusUpdated, newReply, ticketAssigned }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotifType type;
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.ticketId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      type: NotifType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotifType.ticketCreated,
      ),
      ticketId: json['ticket_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'ticket_id': ticketId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
