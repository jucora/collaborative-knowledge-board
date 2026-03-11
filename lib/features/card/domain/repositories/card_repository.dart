import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../entities/card_item.dart';

/// Abstract definition for Card operations.
abstract class CardRepository {
  /// Fetches cards for a specific column.
  Future<Either<Failure, List<CardItem>>> getCards(String columnId);

  /// Creates a new card in the storage.
  Future<Either<Failure, CardItem>> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  });

  /// Updates an existing card's information.
  Future<Either<Failure, CardItem>> updateCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  });

  /// Deletes a card by its ID.
  Future<Either<Failure, void>> deleteCard(String cardId);

  /// Returns a stream of real-time events related to cards.
  /// This allows the UI to react to changes made by other users/devices.
  Stream<RealTimeEvent> watchCards();
}