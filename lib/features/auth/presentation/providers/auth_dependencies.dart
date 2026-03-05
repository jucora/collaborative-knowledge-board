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

/// Auth Repository Provider
final authRepositoryProvider =
Provider<AuthRepository>((ref) {

  final secureStorage = ref.read(secureStorageProvider);
  const useFake = true; // Change to false to use real implementation.

  if (useFake) {
    return FakeAuthRepositoryImpl(
      secureStorage: secureStorage,
    );
  }
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