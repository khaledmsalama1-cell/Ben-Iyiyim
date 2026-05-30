import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../../../contacts/presentation/bloc/contacts_bloc.dart';
import '../../../contacts/presentation/bloc/contacts_state.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';
import '../widgets/map_locator_view.dart';
import '../widgets/shared_contact_tile.dart';

class AlertSendingScreen extends StatefulWidget {
  const AlertSendingScreen({super.key});

  @override
  State<AlertSendingScreen> createState() => _AlertSendingScreenState();
}

class _AlertSendingScreenState extends State<AlertSendingScreen> {
  final Set<String> _sharedContactIds = {};
  Timer? _simulationTimer;
  List<ContactEntity> _allContacts = [];

  @override
  void initState() {
    super.initState();
    final contactsState = context.read<ContactsBloc>().state;
    if (contactsState.status == ContactsStatus.loaded || contactsState.status == ContactsStatus.actionSuccess) {
      _allContacts = contactsState.contacts;
      _startSimulation();
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    int index = 0;
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      if (index < _allContacts.length) {
        setState(() {
          _sharedContactIds.add(_allContacts[index].id);
        });
        index++;
      } else {
        _simulationTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state.status == EmergencyStatus.sent) {
          context.go(AppRoutes.home);
          AppSnackBar.showSuccess(
            context,
            '${state.notifiedCount} kişiye durumunuz iletildi.',
          );
        } else if (state.status == EmergencyStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildStatusText(),
              AppSpacing.gapHXXl,
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: MapLocatorView(),
              ).animate().fadeIn(delay: 200.ms),

              AppSpacing.gapHXXl,
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                  'Emergency Contacts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              AppSpacing.gapHSm,

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  itemCount: _allContacts.isEmpty ? 1 : _allContacts.length,
                  itemBuilder: (context, index) {
                    if (_allContacts.isEmpty) {
                      return SharedContactTile(
                        name: 'Mom',
                        initial: 'M',
                        isShared: _sharedContactIds.contains('mom'),
                      );
                    }
                    final contact = _allContacts[index];
                    return SharedContactTile(
                      name: contact.name,
                      initial: contact.name.isNotEmpty ? contact.name[0] : '?',
                      isShared: _sharedContactIds.contains(contact.id),
                    );
                  },
                ),
              ),

              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 24),
          AppSpacing.gapWSm,
          Text(
            'SafetyNet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sending alerts...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 300.ms),
          AppSpacing.gapHXs,
          Text(
            'Your live location is being securely transmitted.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<EmergencyBloc>().add(ResetEmergencyEvent());
          context.go(AppRoutes.home);
        },
        icon: const Icon(Icons.close, size: 20),
        label: const Text(
          'Cancel Alert',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }
}
