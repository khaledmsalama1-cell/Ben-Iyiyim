import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../../../contacts/presentation/bloc/contacts_bloc.dart';
import '../../../contacts/presentation/bloc/contacts_state.dart';
import '../../domain/entities/emergency_status_entity.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';

class StatusUpdateScreen extends StatelessWidget {
  const StatusUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0F1E36)),
          onPressed: () {
            AppSnackBar.showSuccess(context, 'Menü açılıyor...');
          },
        ),
        title: const Text(
          'Status Update',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F1E36),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF0F1E36)),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Main screen titles
              const Text(
                'Quick Status Update',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F1E36),
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              const Text(
                'Please select your current status below. This will notify your emergency contacts.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF718096),
                ),
              ).animate().fadeIn(delay: 150.ms),
              
              const SizedBox(height: 40),
              
              // Status Cards
              _buildStatusCard(
                context: context,
                title: 'I am safe',
                color: const Color(0xFF34A853), // Google Green
                icon: Icons.check,
                statusType: EmergencyStatusType.safe,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 16),
              
              _buildStatusCard(
                context: context,
                title: 'I need help',
                color: const Color(0xFF4285F4), // Google Blue
                icon: Icons.question_mark,
                statusType: EmergencyStatusType.needHelp,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 16),
              
              _buildStatusCard(
                context: context,
                title: 'I am injured',
                color: const Color(0xFFEA4335), // Google Red
                icon: Icons.medical_services,
                statusType: EmergencyStatusType.injured,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required EmergencyStatusType statusType,
  }) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendStatus(context, statusType),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Circle Icon Holder
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendStatus(BuildContext context, EmergencyStatusType status) {
    final authState = context.read<AuthBloc>().state;
    final contactsState = context.read<ContactsBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      AppSnackBar.showError(context, 'Oturum açmış kullanıcı bulunamadı.');
      return;
    }

    final user = authState.user!;
    final List<ContactEntity> contacts = contactsState.contacts;

    // Trigger Bloc event
    context.read<EmergencyBloc>().add(
          SendSafeStatusEvent(
            uid: user.uid,
            userName: user.displayName,
            contacts: contacts,
            status: status,
          ),
        );

    // Immediately route to Alert Sending Screen
    context.push(AppRoutes.alertSending);
  }
}
