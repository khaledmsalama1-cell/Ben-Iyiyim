import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Core
import '../network/network_info.dart';
import '../services/analytics_service.dart';
import '../services/fcm_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Contacts feature
import '../../features/contacts/data/datasources/contacts_remote_datasource.dart';
import '../../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../../features/contacts/domain/repositories/contacts_repository.dart';
import '../../features/contacts/domain/usecases/add_contact_usecase.dart';
import '../../features/contacts/domain/usecases/delete_contact_usecase.dart';
import '../../features/contacts/domain/usecases/get_contacts_usecase.dart';
import '../../features/contacts/domain/usecases/update_contact_usecase.dart';
import '../../features/contacts/presentation/bloc/contacts_bloc.dart';

// Emergency feature
import '../../features/emergency/data/datasources/emergency_remote_datasource.dart';
import '../../features/emergency/data/repositories/emergency_repository_impl.dart';
import '../../features/emergency/domain/repositories/emergency_repository.dart';
import '../../features/emergency/domain/usecases/send_safe_status_usecase.dart';
import '../../features/emergency/presentation/bloc/emergency_bloc.dart';

// Profile feature
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Registers all dependencies using get_it
/// Call this once before runApp()
Future<void> configureDependencies() async {
  // === THIRD-PARTY / FLUTTER SERVICES ===
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  getIt.registerLazySingleton<FirebaseCrashlytics>(() => FirebaseCrashlytics.instance);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
  getIt.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
        ),
      ));

  // === CORE SERVICES ===
  getIt.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(getIt()),
  );
  getIt.registerLazySingleton<FirestoreService>(
    () => FirestoreService(getIt()),
  );
  getIt.registerLazySingleton<FcmService>(
    () => FcmService(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(getIt()),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // === AUTH FEATURE ===
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton<ForgotPasswordUseCase>(() => ForgotPasswordUseCase(getIt()));
  getIt.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase(getIt()));
  // BLoC (singleton so one instance persists across navigation)
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      getIt(), getIt(), getIt(), getIt(), getIt(), getIt(),
    ),
  );

  // === CONTACTS FEATURE ===
  // Data Sources
  getIt.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSourceImpl(getIt()),
  );
  // Repositories
  getIt.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton<GetContactsUseCase>(() => GetContactsUseCase(getIt()));
  getIt.registerLazySingleton<AddContactUseCase>(() => AddContactUseCase(getIt()));
  getIt.registerLazySingleton<UpdateContactUseCase>(() => UpdateContactUseCase(getIt()));
  getIt.registerLazySingleton<DeleteContactUseCase>(() => DeleteContactUseCase(getIt()));
  // BLoC (factory - new instance per screen visit)
  getIt.registerFactory<ContactsBloc>(
    () => ContactsBloc(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  // === EMERGENCY FEATURE ===
  // Data Sources
  getIt.registerLazySingleton<EmergencyRemoteDataSource>(
    () => EmergencyRemoteDataSourceImpl(getIt()),
  );
  // Repositories
  getIt.registerLazySingleton<EmergencyRepository>(
    () => EmergencyRepositoryImpl(getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton<SendSafeStatusUseCase>(
    () => SendSafeStatusUseCase(getIt()),
  );
  // BLoC (factory)
  getIt.registerFactory<EmergencyBloc>(
    () => EmergencyBloc(getIt(), getIt(), getIt()),
  );

  // === PROFILE FEATURE ===
  // Data Sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt(), getIt()),
  );
  // Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(getIt()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(() => UpdateProfileUseCase(getIt()));
  // BLoC (factory)
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getIt(), getIt(), getIt()),
  );
}
