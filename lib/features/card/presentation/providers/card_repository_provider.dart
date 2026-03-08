import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fake_card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import 'card_datasource_provider.dart';

final cardRepositoryProvider =
Provider<CardRepository>((ref) {
  final datasource = ref.watch(cardDataSourceProvider);
  return FakeCardRepositoryImpl(datasource);
});