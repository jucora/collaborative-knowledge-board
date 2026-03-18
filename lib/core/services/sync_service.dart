import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/card/presentation/providers/card_repository_provider.dart';
import 'real_time_service.dart';

class PendingAction {
  final String id;
  final String type;
  final dynamic data;
  final DateTime createdAt;

  PendingAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });
}

class SyncService extends ChangeNotifier {
  final List<PendingAction> _queue = [];
  final Ref _ref;
  bool _isSyncing = false;

  SyncService(this._ref);

  bool get isSyncing => _isSyncing;
  List<PendingAction> get pendingActions => List.unmodifiable(_queue);

  void addAction(String type, dynamic data) {
    final action = PendingAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
    _queue.add(action);
    notifyListeners();
    if (kDebugMode) {
      print('Offline: Action queued - $type. Total: ${_queue.length}');
    }
  }

  Future<void> sync() async {
    if (_queue.isEmpty || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();
    if (kDebugMode) {
      print('>>> SYNC START: Processing ${_queue.length} actions');
    }
    
    final List<PendingAction> actionsToProcess = List.from(_queue);
    
    for (final action in actionsToProcess) {
      await _processAction(action);
      _queue.removeWhere((a) => a.id == action.id);
      notifyListeners();
    }
    
    _isSyncing = false;
    notifyListeners();
    if (kDebugMode) {
      print('>>> SYNC COMPLETE');
    }

    // Force all Notifiers to refresh from the now-updated FakeDatabase
    _ref.read(realTimeServiceProvider).notify(RealTimeEventType.cardUpdated, null);
  }

  Future<void> _processAction(PendingAction action) async {
    // Artificial delay to simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    
    final cardRepository = _ref.read(cardRepositoryProvider);
    final realTimeService = _ref.read(realTimeServiceProvider);
    
    if (action.type == 'createCard' || action.type == 'updateCard') {
      final card = action.data;
      
      // Update the FakeDatabase via the repository
      await cardRepository.updateCard(
        id: card.id,
        columnId: card.columnId,
        title: card.title,
        description: card.description,
        position: card.position,
        createdBy: card.createdBy,
        createdAt: card.createdAt,
      );
      
      // Notify other parts of the app
      realTimeService.notify(
        action.type == 'createCard' ? RealTimeEventType.cardCreated : RealTimeEventType.cardUpdated, 
        card
      );
    }
  }
}

final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  return SyncService(ref);
});
