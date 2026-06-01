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
}
