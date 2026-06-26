import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<UserEntity> call(SignInParams params) async {
    return await _repository.signIn(params.email, params.password);
  }
}

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<UserEntity> call(SignUpParams params) async {
    return await _repository.signUp(
      params.email,
      params.password,
      params.name,
    );
  }
}

class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<void> call() async {
    return await _repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}