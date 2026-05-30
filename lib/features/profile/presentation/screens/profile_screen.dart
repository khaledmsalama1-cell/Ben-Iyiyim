import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/feedback/error_widget.dart';
import '../../../../shared/widgets/appbars/app_header.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/dialogs/app_dialogs.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_tile.dart';
import '../widgets/profile_bottom_sheets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated || authState.user == null) return const SizedBox.shrink();

        // Trigger load event from global ProfileBloc
        context.read<ProfileBloc>().add(LoadProfileEvent(authState.user!.uid));

        return _ProfileBody(uid: authState.user!.uid);
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final String uid;

  const _ProfileBody({required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: _blocListener,
      builder: (context, state) {
        return Scaffold(
          appBar: const AppHeader(
            title: 'Settings',
            actions: [], // Override to no actions if necessary
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  void _blocListener(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.actionSuccess && state.successMessage != null) {
      AppSnackBar.showSuccess(context, state.successMessage!);
    } else if (state.status == ProfileStatus.error && state.errorMessage != null) {
      AppSnackBar.showError(context, state.errorMessage!);
    } else if (state.status == ProfileStatus.accountDeleted) {
      context.go(AppRoutes.login);
    }
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ProfileStatus.error && state.profile == null) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'Bir hata oluştu',
        onRetry: () => context.read<ProfileBloc>().add(LoadProfileEvent('')), // UID handled in bloc via stream/auth
      );
    }

    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildProfileHeader(context, profile).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
          AppSpacing.gapHXXl,
          
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                description: 'Manage alert sounds and vibration',
                onTap: () => ProfileBottomSheets.showNotificationsConfig(context),
              ),
              SettingsTile(
                icon: Icons.people_outline,
                title: 'Emergency Contacts',
                description: 'Quick access to 5 trusted contacts',
                onTap: () => context.go(AppRoutes.contacts),
              ),
              SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Safety Settings',
                description: 'SOS countdown, location sharing',
                onTap: () => ProfileBottomSheets.showSafetySettingsConfig(context),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
          
          AppSpacing.gapHLg,

          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Security',
                description: 'Password, biometric login',
                onTap: () => ProfileBottomSheets.showSecurityConfig(context),
              ),
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                description: 'FAQ and emergency guides',
                onTap: () => ProfileBottomSheets.showHelpSupportConfig(context),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

          AppSpacing.gapHHuge,

          AppButton(
            label: 'Log Out',
            style: AppButtonStyle.outline,
            onPressed: () => _showSignOutDialog(context),
          ).animate().fadeIn(delay: 250.ms),

          AppSpacing.gapHLg,

          TextButton(
            onPressed: () => _showDeleteAccountDialog(context),
            child: Text(
              'Delete Account',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),

          AppSpacing.gapHXXl,
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Container(
      padding: AppSpacing.edgeInsetsAllXl,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          AvatarWidget(
            displayName: profile.displayName,
            photoUrl: profile.photoUrl,
          ),
          AppSpacing.gapWXl,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                AppSpacing.gapHXs,
                GestureDetector(
                  onTap: () => context.push(AppRoutes.editProfile),
                  child: Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) async {
    final confirmed = await AppDialogs.showConfirmation(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your account?',
      confirmText: 'Log Out',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthSignOutEvent());
    }
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await AppDialogs.showConfirmation(
      context: context,
      title: 'Delete Account',
      message: 'Your account and all associated safety data will be permanently deleted. This action cannot be undone. Do you wish to proceed?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<ProfileBloc>().add(DeleteAccountEvent(uid));
    }
  }
}
