import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/dummy/dummy_tickets.dart';
import '../data/dummy/dummy_comments.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

// ── Ticket list state
class TicketState {
  final List<TicketModel> tickets;
  final bool isLoading;
  final String? error;
  final TicketStatus? filterStatus;

  const TicketState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
  });

  List<TicketModel> get filtered =>
      filterStatus == null ? tickets : tickets.where((t) => t.status == filterStatus).toList();

  TicketState copyWith({
    List<TicketModel>? tickets,
    bool? isLoading,
    String? error,
    TicketStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

class TicketNotifier extends StateNotifier<TicketState> {
  TicketNotifier(this.ref) : super(const TicketState()) {
    _loadTickets();
  }

  final Ref ref;

  void _loadTickets() {
    state = state.copyWith(isLoading: true);
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;

    if (currentUser == null) return;

    List<TicketModel> tickets;
    if (currentUser.role == UserRole.user) {
      // User hanya lihat tiketnya sendiri
      tickets = dummyTickets.where((t) => t.reporterId == currentUser.id).toList();
    } else {
      // Helpdesk & Admin lihat semua
      tickets = List.from(dummyTickets);
    }

    tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(tickets: tickets, isLoading: false);
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required TicketPriority priority,
    required TicketCategory category,
    List<String> attachments = const [],
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));

    final currentUser = ref.read(authProvider).currentUser!;
    final ticketId = 'TKT-${(state.tickets.length + 1).toString().padLeft(3, '0')}';
    final newTicket = TicketModel(
      id: ticketId,
      title: title,
      description: description,
      status: TicketStatus.open,
      priority: priority,
      category: category,
      reporterId: currentUser.id,
      attachments: attachments,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      tickets: [newTicket, ...state.tickets],
      isLoading: false,
    );
  }

  Future<void> updateStatus(String ticketId, TicketStatus newStatus) async {
    final idx = state.tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) return;

    final updated = state.tickets[idx].copyWith(status: newStatus);
    final newList = List<TicketModel>.from(state.tickets);
    newList[idx] = updated;
    state = state.copyWith(tickets: newList);
  }

  Future<void> assignTicket(String ticketId, String helpdeskId) async {
    final idx = state.tickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) return;

    final updated = state.tickets[idx].copyWith(assignedToId: helpdeskId);
    final newList = List<TicketModel>.from(state.tickets);
    newList[idx] = updated;
    state = state.copyWith(tickets: newList);
  }

  void setFilter(TicketStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }
}

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>(
  (ref) => TicketNotifier(ref),
);

// ── Comment provider (per tiket)
class CommentNotifier extends StateNotifier<List<CommentModel>> {
  CommentNotifier(this.ticketId) : super([]) {
    _load();
  }

  final String ticketId;

  void _load() {
    state = dummyComments.where((c) => c.ticketId == ticketId).toList();
  }

  Future<void> addComment(String authorId, String content, {bool isInternal = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final comment = CommentModel(
      id: const Uuid().v4(),
      ticketId: ticketId,
      authorId: authorId,
      content: content,
      createdAt: DateTime.now(),
      isInternal: isInternal,
    );
    state = [...state, comment];
  }
}

final commentProvider = StateNotifierProvider.family<CommentNotifier, List<CommentModel>, String>(
  (ref, ticketId) => CommentNotifier(ticketId),
);
