import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepositoryImpl implements AuthRepository {
  final SecureStorageService secureStorage;

  FakeAuthRepositoryImpl({
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "test@test.com" && password == "123456") {
      const fakeToken = "fake_jwt_token_123";

      final session = AuthSession(
        userId: "1",
        token: fakeToken,
        expiresAt: DateTime.now().add(
          const Duration(hours: 1),
        ),
      );

      await secureStorage.saveToken(fakeToken);

      return Right(session);
    }

    return Left(AuthFailure("Invalid credentials"));
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!email.contains("@")) {
      return Left(AuthFailure("Invalid email"));
    }

    const fakeToken = "fake_jwt_token_123";

    final session = AuthSession(
      userId: "1",
      token: fakeToken,
      expiresAt: DateTime.now().add(
        const Duration(hours: 1),
      ),
    );

    await secureStorage.saveToken(fakeToken);

    return Right(session);
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearToken();
  }
}