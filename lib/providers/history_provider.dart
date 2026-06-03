import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/history_model.dart';
import '../main.dart'; // import supabase client

class HistoryState {
  final List<HistoryModel> histories;
  final bool isLoading;

  HistoryState({this.histories = const [], this.isLoading = false});
}

class HistoryNotifier extends Notifier<HistoryState> {
  final String ticketId;
  HistoryNotifier(this.ticketId);

  @override
  HistoryState build() {
    Future.microtask(() => _loadHistories());
    return HistoryState(isLoading: true);
  }

  Future<void> _loadHistories() async {
    try {
      final response = await supabase.from('histories').select().eq('ticket_id', ticketId).order('created_at', ascending: false);
      final histories = response.map((data) => HistoryModel.fromJson(data)).toList();
      state = HistoryState(histories: histories, isLoading: false);
    } catch (e) {
      state = HistoryState(histories: [], isLoading: false);
    }
  }

  Future<void> addHistory({
    required HistoryAction action,
    required String description,
    required String actorId,
  }) async {
    try {
      final history = HistoryModel(
        id: const Uuid().v4(),
        ticketId: ticketId,
        action: action,
        description: description,
        createdAt: DateTime.now(),
        actorId: actorId,
      );
      
      await supabase.from('histories').insert(history.toJson());
      state = HistoryState(histories: [history, ...state.histories], isLoading: false);
    } catch (e) {
      // Handle error
    }
  }
}

final historyProvider = NotifierProvider.family<HistoryNotifier, HistoryState, String>(
  (ticketId) => HistoryNotifier(ticketId),
);
