import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/auth_usecases.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const SignUpRequested(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

class SignOutRequested extends AuthEvent {}

class GetCurrentUser extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String? name;
  final bool isAdmin;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    this.name,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [userId, email, name, isAdmin];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
  ) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GetCurrentUser>(_onGetCurrentUser);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,           // ✅ id مش uid
          email: user.email,
          name: user.name,
          isAdmin: user.isAdmin,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // ✅ نستخدم SignInParams
      final user = await _signInUseCase(
        SignInParams(email: event.email, password: event.password),
      );
      emit(AuthAuthenticated(
        userId: user.id,            // ✅ id مش uid
        email: user.email,
        name: user.name,
        isAdmin: user.isAdmin,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // ✅ نستخدم SignUpParams
      final user = await _signUpUseCase(
        SignUpParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      emit(AuthAuthenticated(
        userId: user.id,            // ✅ id مش uid
        email: user.email,
        name: user.name,
        isAdmin: user.isAdmin,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ✅ تسجيل الخروج
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
      emit(AuthUnauthenticated());    // ✅ لازم يبعت AuthUnauthenticated
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,           // ✅ id مش uid
          email: user.email,
          name: user.name,
          isAdmin: user.isAdmin,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}