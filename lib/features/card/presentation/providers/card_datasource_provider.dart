// lib/features/card/presentation/providers/card_datasource_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../../../core/providers/config_provider.dart'; // Importamos la config global
import '../../data/datasources/card_remote_datasource.dart';
import '../../data/datasources/fake_card_datasource.dart';
import '../../data/datasources/supabase_card_datasource_impl.dart';

final cardDataSourceProvider = Provider<CardRemoteDataSource>((ref) {
  if (useFakeData) {
    final database = ref.watch(fakeDatabaseProvider);
    return FakeCardDatasource(database);
  }
  return SupabaseCardDataSourceImpl();
});