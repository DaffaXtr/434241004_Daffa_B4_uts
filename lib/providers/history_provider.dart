import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/dummy/dummy_histories.dart';
import '../models/history_model.dart';

class HistoryNotifier extends Notifier<List<HistoryModel>> {
  final String ticketId;
  HistoryNotifier(this.ticketId);

  @override
  List<HistoryModel> build() {
    final histories = dummyHistories.where((h) => h.ticketId == ticketId).toList();
    histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return histories;
  }

  void addHistory({
    required HistoryAction action,
    required String description,
    required String actorId,
  }) {
    final history = HistoryModel(
      id: const Uuid().v4(),
      ticketId: ticketId,
      action: action,
      description: description,
      createdAt: DateTime.now(),
      actorId: actorId,
    );
    
    state = [history, ...state];
  }
}

final historyProvider = NotifierProvider.family<HistoryNotifier, List<HistoryModel>, String>(
  (ticketId) => HistoryNotifier(ticketId),
);
