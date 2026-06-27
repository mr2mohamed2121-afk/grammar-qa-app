import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';

// ✅ Services - الموجودين في lib/core/services/ (اللي أنا كتبتهم)
import 'core/services/security_service.dart';
import 'core/services/cache_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/analytics_service.dart';

// ✅ Services - الموجودين في lib/services/ (اللي عندك)
import 'services/biometric_service.dart';
import 'services/firestore_service.dart';
import 'services/payment_service.dart';
import 'services/admob_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ==================== EXTERNAL ====================
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ==================== SERVICES (core/services) ====================
  getIt.registerLazySingleton(() => SecurityService());
  getIt.registerLazySingleton(() => CacheService());
  getIt.registerLazySingleton(() => NotificationService());
  getIt.registerLazySingleton(() => AnalyticsService());

  // ==================== SERVICES (lib/services) ====================
  getIt.registerLazySingleton(() => BiometricService());
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => PaymentService());
  getIt.registerLazySingleton(() => AdmobService());

  // ==================== AUTH ====================
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // AuthBloc as Singleton
  getIt.registerLazySingleton(() => AuthBloc(
    getIt<SignInUseCase>(),
    getIt<SignUpUseCase>(),
    getIt<SignOutUseCase>(),
    getIt<GetCurrentUserUseCase>(),
  ));
}