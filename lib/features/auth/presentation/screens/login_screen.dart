import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/forms/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/social_auth_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          AuthSignInEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.home);
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      AppSpacing.gapHXXXL,
                      
                      AppTextField(
                        label: 'Email',
                        hint: 'jane@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: Validators.validateEmail,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      AppSpacing.gapHLg,

                      AppTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: Validators.validatePassword,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onLogin(),
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                      AppSpacing.gapHMd,

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          child: const Text('Forgot Password?'),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      AppSpacing.gapHXXl,

                      AppButton(
                        label: 'Login',
                        onPressed: _onLogin,
                        isLoading: isLoading,
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

                      AppSpacing.gapHXXl,
                      _buildDivider().animate().fadeIn(delay: 400.ms),
                      AppSpacing.gapHXXl,

                      SocialAuthButton(
                        label: 'Google',
                        isGoogle: true,
                        onPressed: () => AppSnackBar.showSuccess(context, 'Google ile giriş yapılıyor...'),
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                      AppSpacing.gapHMd,
                      
                      SocialAuthButton(
                        label: 'Apple',
                        isGoogle: false,
                        onPressed: () => AppSnackBar.showSuccess(context, 'Apple ile giriş yapılıyor...'),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                      AppSpacing.gapHXXXL,
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 550.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.shield, color: Theme.of(context).colorScheme.primary, size: 32),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.bounceInOut),
        AppSpacing.gapHLg,
        Text(
          'SafetyFirst',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 100.ms),
        AppSpacing.gapHXs,
        Text(
          'Sign in. Safety starts here.',
          style: Theme.of(context).textTheme.titleMedium,
        ).animate().fadeIn(delay: 150.ms),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text('or sign in with', style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}
