import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/contacts/presentation/bloc/contacts_bloc.dart';
import '../../features/contacts/presentation/bloc/contacts_event.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/emergency/presentation/screens/home_screen.dart';
import '../../features/emergency/presentation/screens/status_update_screen.dart';
import '../../features/emergency/presentation/screens/alert_sending_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

/// App router configuration using go_router
/// Handles deep linking, auth guards, and bottom nav shell
class AppRouter {
  AppRouter._();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (_, __) => const ForgotPasswordScreen(),
          ),
        ],
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.contacts,
            builder: (context, __) {
              final authBloc = context.read<AuthBloc>();
              final authState = authBloc.state;
              String uid = '';
              if (authState.status == AuthStatus.authenticated && authState.user != null) uid = authState.user!.uid;
              return BlocProvider(
                create: (_) =>
                    getIt<ContactsBloc>()..add(LoadContactsEvent(uid)),
                child: const ContactsScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.statusUpdate,
            builder: (_, __) => const StatusUpdateScreen(),
          ),
        ],
      ),

      // Modal / detail routes (outside shell)
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.alertSending,
        builder: (_, __) => const AlertSendingScreen(),
      ),
    ],
  );

  /// Redirect logic: protect main routes from unauthenticated access
  static String? _redirect(BuildContext context, GoRouterState state) {
    // Let splash handle initial routing
    return null;
  }
}

/// Bottom navigation shell widget
class _MainShell extends StatefulWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  static const _routes = [
    AppRoutes.home,
    AppRoutes.contacts,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    if (location.startsWith(AppRoutes.contacts)) {
      selectedIndex = 1;
    } else if (location.startsWith(AppRoutes.profile)) {
      selectedIndex = 2;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context, selectedIndex),
    );
  }

  Widget _buildBottomNav(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
