import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import 'board_notifier.dart';

/// Board Notifier Provider
final boardNotifierProvider =
AsyncNotifierProvider<BoardNotifier, List<Board>>(
      () {
    return BoardNotifier();
  },
);