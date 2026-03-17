import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/card_remote_datasource.dart';
import '../../data/datasources/fake_card_datasource.dart';
import '../../data/datasources/supabase_card_datasource_impl.dart';

/// Provider for the Remote Data Source (Supabase)
final remoteCardDataSourceProvider = Provider<CardRemoteDataSource>((ref) {
  return SupabaseCardDataSourceImpl();
});

/// Provider for the Local Data Source (FakeDB acts as Cache)
final localCardDataSourceProvider = Provider<CardRemoteDataSource>((ref) {
  final database = ref.watch(fakeDatabaseProvider);
  return FakeCardDatasource(database);
});

/// Legacy provider for backward compatibility if needed
final cardDataSourceProvider = Provider<CardRemoteDataSource>((ref) {
  return ref.watch(remoteCardDataSourceProvider);
});
