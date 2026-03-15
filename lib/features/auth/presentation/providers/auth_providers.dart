import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/supabase_auth_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/fake_auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// 🔹 Datasource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Aquí usamos la implementación de Supabase
  return SupabaseAuthDataSourceImpl();
});

/// Control flag to toggle between Fake and Real Implementation
const useFake = false;

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  if (useFake) {
    return FakeAuthRepositoryImpl(
      secureStorage: secureStorage,
    );
  }

  // Implementación Real con Supabase
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

/// Login UseCase Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Register UseCase Provider
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return RegisterUseCase(repository);
});
