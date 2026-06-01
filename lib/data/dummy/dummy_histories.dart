import '../../models/history_model.dart';

final dummyHistories = [
  HistoryModel(
    id: 'h001',
    ticketId: 'TKT-001',
    action: HistoryAction.created,
    description: 'Tiket berhasil dibuat',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    actorId: 'u1', // Budi Santoso (User)
  ),
  HistoryModel(
    id: 'h002',
    ticketId: 'TKT-002',
    action: HistoryAction.created,
    description: 'Tiket berhasil dibuat',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    actorId: 'u2', // Siti Aminah (User)
  ),
  HistoryModel(
    id: 'h003',
    ticketId: 'TKT-002',
    action: HistoryAction.statusUpdated,
    description: 'Status diubah menjadi In Progress',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    actorId: 'h1', // Andi Wijaya (Helpdesk)
  ),
  HistoryModel(
    id: 'h004',
    ticketId: 'TKT-003',
    action: HistoryAction.created,
    description: 'Tiket berhasil dibuat',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    actorId: 'u1',
  ),
];
