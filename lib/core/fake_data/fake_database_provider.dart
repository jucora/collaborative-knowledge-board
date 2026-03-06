import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fake_data_generator.dart';
import 'fake_database.dart';

/// Provider global que crea una base de datos fake en memoria.
///
/// Se instancia una sola vez durante toda la vida de la app.
final fakeDatabaseProvider = Provider<FakeDatabase>((ref) {
  return FakeDataGenerator.generate();
});