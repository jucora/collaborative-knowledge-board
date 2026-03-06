import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/fake_card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';

class  CardProviders {
  // Repository Provider for Board Members
  final cardRepositoryProvider = Provider<CardRepository>((ref) {
    if (useFake) {
      return FakeCardRepositoryImpl();
    }
    return throw UnimplementedError(
      'Implement CardRepository when using a real API',
    );
  });
}