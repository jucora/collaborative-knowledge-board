import 'package:collaborative_knowledge_board/features/card/data/datasources/fake_card_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';

final cardDataSourceProvider =
Provider<FakeCardDatasource>((ref){
  final database = ref.watch(fakeDatabaseProvider);
  return FakeCardDatasource(database);
});