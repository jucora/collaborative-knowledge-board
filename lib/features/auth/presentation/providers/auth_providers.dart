import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/fake_auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// 🔹 Datasource Provider (solo usado en implementación real)
final authRemoteDataSourceProvider =
Provider<AuthRemoteDataSource>((ref) {

  throw UnimplementedError(
    'Implement AuthRemoteDataSource when using a real API',
  );
});

const useFake = true; // Change to false to use real implementation.

/// Auth Repository Provider
final authRepositoryProvider =
Provider<AuthRepository>((ref) {

  final secureStorage = ref.read(secureStorageProvider);

  if (useFake) {
    return FakeAuthRepositoryImpl(
      secureStorage: secureStorage,
    );
  }
  return throw UnimplementedError(
    'Implement AuthRepository when using a real API',
  );
});

/// Login UseCase Provider
final loginUseCaseProvider =
Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Register UseCase Provider
final registerUseCaseProvider =
Provider<RegisterUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return RegisterUseCase(repository);
});