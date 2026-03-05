import 'package:dartz/dartz.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.login(email, password);

      // Guardamos el token
      await secureStorage.saveToken(model.token);

      // Convertimos a AuthSession (NO a User)
      final session = AuthSession(
        userId: model.id,
        token: model.token,
        expiresAt: model.expiresAt, // debe venir del model
      );

      return Right(session);
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.register(email, password);

      await secureStorage.saveToken(model.token);

      final session = AuthSession(
        userId: model.id,
        token: model.token,
        expiresAt: model.expiresAt,
      );

      return Right(session);
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearToken();
  }
}