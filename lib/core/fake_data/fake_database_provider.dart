import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fake_data_generator.dart';
import 'fake_database.dart';

final fakeDatabaseProvider = Provider<FakeDatabase>((ref) {
  return FakeDataGenerator.generate();
});