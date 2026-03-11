import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defines the types of events that can happen in real-time.
enum RealTimeEventType {
  cardCreated,
  cardUpdated,
  cardDeleted,
  commentCreated,
}

/// Represents a single real-time event carrying a type and the associated data.
class RealTimeEvent {
  final RealTimeEventType type;
  final dynamic data;

  RealTimeEvent(this.type, this.data);
}

/// A service that manages real-time event broadcasting and connection simulation.
/// We use ChangeNotifier so the UI can react to connection status changes.
class RealTimeService extends ChangeNotifier {
  final _controller = StreamController<RealTimeEvent>.broadcast();
  bool _isConnected = true;

  /// Stream of events that repositories and notifiers subscribe to.
  Stream<RealTimeEvent> get eventStream => _controller.stream;
  
  /// Current simulated connection status.
  bool get isConnected => _isConnected;

  /// Broadcasts an event to all subscribers if "connected".
  void notify(RealTimeEventType type, dynamic data) {
    if (_isConnected) {
      _controller.add(RealTimeEvent(type, data));
    }
  }

  /// Toggles the connection status and notifies the UI.
  void setConnection(bool connected) {
    if (_isConnected == connected) return;
    
    _isConnected = connected;
    
    if (connected) {
      // Upon reconnection, we emit a special event (null data) 
      // to signal all listeners to re-sync their state from the Source of Truth.
      _controller.add(RealTimeEvent(RealTimeEventType.cardUpdated, null)); 
    }
    
    // Notify ChangeNotifier listeners (like the Simulator Panel) to rebuild.
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

/// Provider to access the RealTimeService. 
/// Using ChangeNotifierProvider allows widgets to 'watch' the connection status.
final realTimeServiceProvider = ChangeNotifierProvider<RealTimeService>((ref) {
  return RealTimeService();
});
