enum HistoryAction {
  created,
  statusUpdated,
  assigned,
}

extension HistoryActionExtension on HistoryAction {
  String get label {
    switch (this) {
      case HistoryAction.created:
        return 'Tiket Dibuat';
      case HistoryAction.statusUpdated:
        return 'Status Diperbarui';
      case HistoryAction.assigned:
        return 'Ditugaskan';
    }
  }
}

class HistoryModel {
  final String id;
  final String ticketId;
  final HistoryAction action;
  final String description;
  final DateTime createdAt;
  final String actorId;

  const HistoryModel({
    required this.id,
    required this.ticketId,
    required this.action,
    required this.description,
    required this.createdAt,
    required this.actorId,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      ticketId: json['ticket_id'],
      action: HistoryAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => HistoryAction.created,
      ),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      actorId: json['actor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'action': action.name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'actor_id': actorId,
    };
  }
}
