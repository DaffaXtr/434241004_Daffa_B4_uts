import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket_model.dart';
import 'ticket_provider.dart';

class DashboardStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const DashboardStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tickets = ref.watch(ticketProvider).tickets;
  return DashboardStats(
    total: tickets.length,
    open: tickets.where((t) => t.status == TicketStatus.open).length,
    inProgress: tickets.where((t) => t.status == TicketStatus.inProgress).length,
    resolved: tickets.where((t) => t.status == TicketStatus.resolved).length,
    closed: tickets.where((t) => t.status == TicketStatus.closed).length,
  );
});
