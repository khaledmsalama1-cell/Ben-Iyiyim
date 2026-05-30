import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../contacts/presentation/bloc/contacts_bloc.dart';
import '../../../contacts/presentation/bloc/contacts_event.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';
import '../widgets/emergency_button.dart';
import '../widgets/emergency_bottom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      context.read<ContactsBloc>().add(LoadContactsEvent(authState.user!.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated || authState.user == null) return const SizedBox();
        return _HomeBody(uid: authState.user!.uid, userName: authState.user!.displayName);
      },
    );
  }
}

class _HomeBody extends StatelessWidget {
  final String uid;
  final String userName;

  const _HomeBody({required this.uid, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state.status == EmergencyStatus.offline && state.errorMessage != null) {
          _showOfflineDialog(context);
        } else if (state.status == EmergencyStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => AppSnackBar.showSuccess(context, 'Menü açılıyor...'),
            ),
            title: Text(
              'Emergency Mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.profile),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                      color: Colors.grey.shade700,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.darkBackgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  
                  const Icon(Icons.shield_outlined, color: Colors.white38, size: 40)
                      .animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                  AppSpacing.gapHSm,
                  
                  Text(
                    'Emergency Mode',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const Spacer(),
                  
                  Center(
                    child: EmergencyButton(
                      label: "I'm OK",
                      onPressed: () => context.push(AppRoutes.statusUpdate),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                  
                  AppSpacing.gapHXXXL,
                  
                  Text(
                    'Press and hold to alert your contacts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const Spacer(flex: 2),
                  
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Row(
                      children: [
                        Expanded(
                          child: EmergencyBottomCard(
                            title: 'Medical Info',
                            icon: Icons.add_box_outlined,
                            onTap: () => AppSnackBar.showSuccess(context, 'Tıbbi bilgiler yükleniyor...'),
                          ),
                        ),
                        AppSpacing.gapWLg,
                        Expanded(
                          child: EmergencyBottomCard(
                            title: 'Call 911',
                            icon: Icons.phone_in_talk_outlined,
                            onTap: () async {
                              final phoneUri = Uri.parse('tel:911');
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                              } else if (context.mounted) {
                                AppSnackBar.showError(context, 'Arama başlatılamadı');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İnternet Bağlantısı Yok'),
        content: const Text('Bildirim gönderilemiyor. Acil durum kontağlarınıza SMS göndermek ister misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<EmergencyBloc>().add(
                TriggerSmsFallbackEvent(contacts: const [], userName: userName),
              );
            },
            child: const Text('SMS Gönder'),
          ),
        ],
      ),
    );
  }
}
