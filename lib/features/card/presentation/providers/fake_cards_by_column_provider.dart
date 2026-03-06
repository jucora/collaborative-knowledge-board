import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_card_datasource.dart';
import '../../data/repositories/fake_card_repository_impl.dart';
import '../../domain/usecases/get_cards_usecase.dart';

// Fake Cards By Column Provider

final cardsByColumnProvider =
FutureProvider.family<List<CardItem>, String>((ref, columnId) async {

  final database = ref.watch(fakeDatabaseProvider);

  final datasource = FakeCardDatasource(database);

  final repository = FakeCardRepositoryImpl(datasource);

  final useCase = GetCardsUseCase(repository);

  final result = await useCase(columnId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (cards) => cards,
  );
});