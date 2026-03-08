import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comment/presentation/providers/comment_datasource_provider.dart';
import '../../data/repositories/fake_card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import 'card_datasource_provider.dart';

final cardRepositoryProvider =
Provider<CardRepository>((ref) {
  final datasource = ref.watch(cardDataSourceProvider);
  final commentDatasource = ref.watch(commentDataSourceProvider);
  return FakeCardRepositoryImpl(datasource, commentDatasource);
});