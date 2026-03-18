import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/config_provider.dart';
import 'fake_data_generator.dart';
import 'fake_database.dart';

final fakeDatabaseProvider = Provider<FakeDatabase>((ref) {
  // If useFakeData is true, we generate dummy data for testing.
  if (useFakeData) {
    return FakeDataGenerator.generate();
  }
  
  // If useFakeData is false, we start with an EMPTY database.
  // This empty database will act as our "Local Cache" for Supabase data.
  return FakeDatabase(
    users: [],
    boards: [],
    members: [],
    columns: [],
    cards: [],
    comments: [],
  );
});
