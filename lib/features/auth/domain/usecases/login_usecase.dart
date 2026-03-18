import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthSession>> call(
      String email,
      String password,
      ) {
    return repository.login(
      email: email,
      password: password,
    );
  }
}