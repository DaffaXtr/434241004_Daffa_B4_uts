import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/history_model.dart';
import 'auth_provider.dart';
import 'history_provider.dart';
import 'user_provider.dart';
import '../main.dart'; // import supabase client

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

class TicketNotifier extends Notifier<TicketState> {
  
  @override
  TicketState build() {
    ref.watch(authProvider.select((state) => state.currentUser));
    Future.microtask(() => _loadTickets());
    return const TicketState();
  }

  Future<void> _loadTickets() async {
    state = state.copyWith(isLoading: true);
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;

    if (currentUser == null) return;

    try {
      late final List<dynamic> response;
      if (currentUser.role == UserRole.user) {
        response = await supabase.from('tickets').select().eq('reporter_id', currentUser.id).order('created_at', ascending: false);
      } else {
        response = await supabase.from('tickets').select().order('created_at', ascending: false);
      }

      final tickets = response.map((data) => TicketModel.fromJson(data)).toList();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required TicketPriority priority,
    required TicketCategory category,
    List<String> attachments = const [],
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final currentUser = ref.read(authProvider).currentUser!;
      final newTicket = TicketModel(
        id: const Uuid().v4(), // Menggunakan UUID v4
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

      await supabase.from('tickets').insert(newTicket.toJson());

      state = state.copyWith(
        tickets: [newTicket, ...state.tickets],
        isLoading: false,
      );

      // Tambahkan log history untuk pembuatan tiket
      ref.read(historyProvider(newTicket.id).notifier).addHistory(
        action: HistoryAction.created,
        description: 'Tiket berhasil dibuat',
        actorId: currentUser.id,
      );

      // Notifikasi ke semua admin dan helpdesk
      final allUsers = ref.read(allUsersProvider);
      final staffUsers = allUsers.where((u) => u.role == UserRole.admin || u.role == UserRole.helpdesk);
      
      if (staffUsers.isNotEmpty) {
        final notifications = staffUsers.map((staff) => NotificationModel(
          id: const Uuid().v4(),
          userId: staff.id,
          title: 'Tiket Baru',
          body: 'Tiket #${newTicket.id.substring(0,8).toUpperCase()} telah dibuat oleh ${currentUser.name}',
          type: NotifType.ticketCreated,
          ticketId: newTicket.id,
          createdAt: DateTime.now(),
        )).toList();
        
        await supabase.from('notifications').insert(notifications.map((n) => n.toJson()).toList());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String ticketId, TicketStatus newStatus) async {
    try {
      await supabase.from('tickets').update({'status': newStatus.name, 'updated_at': DateTime.now().toIso8601String()}).eq('id', ticketId);

      final idx = state.tickets.indexWhere((t) => t.id == ticketId);
      if (idx == -1) return;

      final updated = state.tickets[idx].copyWith(status: newStatus);
      final newList = List<TicketModel>.from(state.tickets);
      newList[idx] = updated;
      state = state.copyWith(tickets: newList);

      // Notifikasi ke pembuat tiket (reporter) jika yang mengubah bukan dirinya
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser != null && currentUser.id != updated.reporterId) {
        final notif = NotificationModel(
          id: const Uuid().v4(),
          userId: updated.reporterId,
          title: 'Status Tiket Diperbarui',
          body: 'Status tiket #${ticketId.substring(0,8).toUpperCase()} telah diubah menjadi ${updated.statusLabel}',
          type: NotifType.statusUpdated,
          ticketId: ticketId,
          createdAt: DateTime.now(),
        );
        await supabase.from('notifications').insert(notif.toJson());
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> assignTicket(String ticketId, String helpdeskId) async {
    try {
      await supabase.from('tickets').update({'assigned_to_id': helpdeskId, 'updated_at': DateTime.now().toIso8601String()}).eq('id', ticketId);
      
      final idx = state.tickets.indexWhere((t) => t.id == ticketId);
      if (idx == -1) return;

      final updated = state.tickets[idx].copyWith(assignedToId: helpdeskId);
      final newList = List<TicketModel>.from(state.tickets);
      newList[idx] = updated;
      state = state.copyWith(tickets: newList);

      // Notifikasi ke staf yang ditugaskan
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser != null && currentUser.id != helpdeskId) {
        final notif = NotificationModel(
          id: const Uuid().v4(),
          userId: helpdeskId,
          title: 'Tiket Ditugaskan',
          body: 'Anda telah ditugaskan untuk menangani tiket #${ticketId.substring(0,8).toUpperCase()}',
          type: NotifType.ticketAssigned,
          ticketId: ticketId,
          createdAt: DateTime.now(),
        );
        await supabase.from('notifications').insert(notif.toJson());
      }
    } catch (e) {
      debugPrint('Error assigning ticket: $e');
    }
  }

  void setFilter(TicketStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }
}

final NotifierProvider<TicketNotifier, TicketState> ticketProvider = NotifierProvider<TicketNotifier, TicketState>(
  () => TicketNotifier(),
);

// ── Comment provider (per tiket)
class CommentState {
  final List<CommentModel> comments;
  final bool isLoading;

  CommentState({this.comments = const [], this.isLoading = false});
}

class CommentNotifier extends Notifier<CommentState> {
  final String ticketId;
  CommentNotifier(this.ticketId);

  @override
  CommentState build() {
    Future.microtask(() => _loadComments());
    return CommentState(isLoading: true);
  }

  Future<void> _loadComments() async {
    try {
      final response = await supabase.from('comments').select().eq('ticket_id', ticketId).order('created_at', ascending: true);
      final comments = response.map((data) => CommentModel.fromJson(data)).toList();
      state = CommentState(comments: comments, isLoading: false);
    } catch (e) {
      state = CommentState(comments: [], isLoading: false);
    }
  }

  Future<void> addComment(String authorId, String content, {bool isInternal = false}) async {
    try {
      final comment = CommentModel(
        id: const Uuid().v4(),
        ticketId: ticketId,
        authorId: authorId,
        content: content,
        createdAt: DateTime.now(),
        isInternal: isInternal,
      );
      
      await supabase.from('comments').insert(comment.toJson());
      state = CommentState(comments: [...state.comments, comment], isLoading: false);

      // Notifikasi
      final currentUser = ref.read(authProvider).currentUser;
      final tickets = ref.read(ticketProvider).tickets;
      final ticketIdx = tickets.indexWhere((t) => t.id == ticketId);
      
      if (currentUser != null && ticketIdx != -1) {
        final ticket = tickets[ticketIdx];
        String? targetUserId;
        
        if (!isInternal && currentUser.id != ticket.reporterId) {
          // Staf komen (publik) -> notif ke reporter
          targetUserId = ticket.reporterId;
        } else if (currentUser.id == ticket.reporterId && ticket.assignedToId != null) {
          // Reporter komen -> notif ke assignee
          targetUserId = ticket.assignedToId;
        }
        
        if (targetUserId != null) {
          final notif = NotificationModel(
            id: const Uuid().v4(),
            userId: targetUserId,
            title: 'Komentar Baru',
            body: 'Ada komentar baru pada tiket #${ticketId.substring(0,8).toUpperCase()}',
            type: NotifType.newReply,
            ticketId: ticketId,
            createdAt: DateTime.now(),
          );
          await supabase.from('notifications').insert(notif.toJson());
        }
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
}

final commentProvider = NotifierProvider.family<CommentNotifier, CommentState, String>(
  (ticketId) => CommentNotifier(ticketId),
);