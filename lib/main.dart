import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/contacts/presentation/bloc/contacts_bloc.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// NOTE: This file requires firebase_options.dart to be generated.
// After you provide google-services.json and GoogleService-Info.plist,
// run: flutterfire configure
// This will generate: lib/firebase_options.dart
//
// Uncomment the following import once firebase_options.dart exists:
import 'firebase_options.dart';

/// Background FCM message handler (top-level, required by Firebase)
// This is defined in fcm_service.dart but referenced here:
// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish locale for date formatting
  await initializeDateFormatting('tr_TR', null);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Disable Crashlytics in debug mode
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Initialize dependency injection
  await configureDependencies();

  // Initialize FCM background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize FCM (notifications)
  await getIt<FcmService>().initialize();

  // Run app
  runApp(const BenIyiyimApp());
}

/// Root application widget
class BenIyiyimApp extends StatelessWidget {
  const BenIyiyimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC is a global singleton - persists entire app lifecycle
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckStatusEvent()),
          lazy: false,
        ),
        BlocProvider<EmergencyBloc>(
          create: (_) => getIt<EmergencyBloc>(),
        ),
        BlocProvider<ContactsBloc>(
          create: (_) => getIt<ContactsBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ben İyiyim',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Forces light mode to match UI designs

        // Router
        routerConfig: AppRouter.router,

        // Localization
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Builder for global overlay support (e.g., loading, dialogs)
        builder: (context, child) {
          // Ensure text scale is bounded for accessibility
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.unauthenticated) {
                AppRouter.router.go(AppRoutes.login);
              }
            },
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.textScalerOf(context).scale(1).clamp(0.8, 1.3),
                ),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
