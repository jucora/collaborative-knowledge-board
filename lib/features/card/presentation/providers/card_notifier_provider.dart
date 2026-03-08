import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import 'card_notifier.dart';

final cardNotifierProvider =
AsyncNotifierProvider.family<CardNotifier, List<CardItem>, String>(
  CardNotifier.new,
);