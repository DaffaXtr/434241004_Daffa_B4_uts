enum TicketStatus { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high, critical }
enum TicketCategory { hardware, software, network, account, other }

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final TicketCategory category;
  final String reporterId; // user yang membuat
  final String? assignedToId; // helpdesk yang ditugaskan
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.reporterId,
    this.assignedToId,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.critical:
        return 'Critical';
    }
  }

  String get categoryLabel {
    switch (category) {
      case TicketCategory.hardware:
        return 'Hardware';
      case TicketCategory.software:
        return 'Software';
      case TicketCategory.network:
        return 'Network';
      case TicketCategory.account:
        return 'Account';
      case TicketCategory.other:
        return 'Other';
    }
  }

  TicketModel copyWith({
    TicketStatus? status,
    String? assignedToId,
  }) {
    return TicketModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      priority: priority,
      category: category,
      reporterId: reporterId,
      assignedToId: assignedToId ?? this.assignedToId,
      attachments: attachments,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
