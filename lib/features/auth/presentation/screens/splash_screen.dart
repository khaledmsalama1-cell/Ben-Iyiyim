import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _activeDotIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Animate the 4-dot loader
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _activeDotIndex = (_activeDotIndex + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Give the splash screen a clean 2 seconds to show before routing
        Future.delayed(const Duration(seconds: 2), () {
          if (!context.mounted) return;
          if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.home);
          } else if (state.status == AuthStatus.unauthenticated) {
            context.go(AppRoutes.login);
          }
        });
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.splashGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon / Logo - Squircle with Shield
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E36), // Deep Navy
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F1E36).withValues(alpha: 0.15),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.easeOutBack)
                          .then(delay: 500.ms)
                          .shake(duration: 800.ms, hz: 2),
                      const SizedBox(height: 24),
                      
                      // App Name
                      const Text(
                        'SafetyFirst',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F1E36),
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      
                      // Subtitle
                      const Text(
                        'ALWAYS SECURE',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF718096),
                          letterSpacing: 4.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      
                      const SizedBox(height: 48),
                      
                      // Animated 4-dot loader
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive = index == _activeDotIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E0),
                            ),
                          );
                        }),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
                
                // Bottom content
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'POWERED BY GOOGLE ',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF718096),
                                letterSpacing: 1.0,
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Color(0xFF718096),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Initializing safety protocols...',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9090A0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
