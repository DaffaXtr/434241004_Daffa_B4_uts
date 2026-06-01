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

// 1. Migrasi TicketNotifier menggunakan Notifier biasa
class TicketNotifier extends Notifier<TicketState> {
  
  // Nilai awal didefinisikan di build() dan panggil _loadTickets() langsung di sini
  @override
  TicketState build() {
    // Karena _loadTickets bersifat synchronous dan langsung mengubah state, 
    // kita bisa panggil atau kembalikan state awal yang sudah terisi.
    Future.microtask(() => _loadTickets());
    return const TicketState();
  }

  void _loadTickets() {
    state = state.copyWith(isLoading: true);
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;

    if (currentUser == null) return;

    List<TicketModel> tickets;
    if (currentUser.role == UserRole.user) {
      tickets = dummyTickets.where((t) => t.reporterId == currentUser.id).toList();
    } else {
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

// Gunakan NotifierProvider biasa
final NotifierProvider<TicketNotifier, TicketState> ticketProvider = NotifierProvider<TicketNotifier, TicketState>(
  () => TicketNotifier(),
);

// ── Comment provider (per tiket)
// 1. Kembalikan ke 'Notifier' biasa, tampung ticketId via constructor
class CommentNotifier extends Notifier<List<CommentModel>> {
  final String ticketId;
  CommentNotifier(this.ticketId);

  // 2. Override build() standar tanpa parameter, langsung gunakan ticketId dari constructor
  @override
  List<CommentModel> build() {
    return dummyComments.where((c) => c.ticketId == ticketId).toList();
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

// 3. Deklarasikan NotifierProvider.family dengan mencocokkan parameter (ref, arg) di fungsi anonimnya
// Deklarasikan NotifierProvider.family dengan membiarkan Dart menebak argumen fungsi pembuatnya
final commentProvider = NotifierProvider.family<CommentNotifier, List<CommentModel>, String>(
  (ticketId) => CommentNotifier(ticketId),
);