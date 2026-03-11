import 'dart:async';
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
/// In a real app, this would be replaced by a WebSocket or Firebase implementation.
class RealTimeService {
  // Using a broadcast stream allows multiple listeners (columns, dialogs)
  // to receive the same event simultaneously.
  final _controller = StreamController<RealTimeEvent>.broadcast();

  // Simulates the current connection status.
  bool _isConnected = true;

  /// Stream of events that UI components can subscribe to.
  Stream<RealTimeEvent> get eventStream => _controller.stream;

  /// Returns whether the service is currently "connected".
  bool get isConnected => _isConnected;

  /// Notifies all listeners about a new event.
  /// If the service is disconnected, events are dropped (simulating offline behavior).
  void notify(RealTimeEventType type, dynamic data) {
    if (_isConnected) {
      _controller.add(RealTimeEvent(type, data));
    }
  }

  /// Sets the connection status.
  /// When reconnecting, it emits a null event to trigger a global data refresh.
  void setConnection(bool connected) {
    _isConnected = connected;
    if (connected) {
      // Notify listeners to re-fetch data to ensure consistency after being offline.
      _controller.add(RealTimeEvent(RealTimeEventType.cardUpdated, null));
    }
  }

  /// Closes the stream controller when the service is no longer needed.
  void dispose() {
    _controller.close();
  }
}

/// Provider to access the RealTimeService instance across the application.
final realTimeServiceProvider = Provider<RealTimeService>((ref) {
  final service = RealTimeService();
  ref.onDispose(() => service.dispose());
  return service;
});
