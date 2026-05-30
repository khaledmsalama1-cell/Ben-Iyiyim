import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/feedback/error_widget.dart';
import '../../../../shared/widgets/loading/shimmer_loading.dart';
import '../../../../shared/widgets/appbars/app_header.dart';
import '../../../../shared/widgets/sheets/app_bottom_sheets.dart';
import '../../../../shared/widgets/dialogs/app_dialogs.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';
import '../../domain/entities/contact_entity.dart';
import '../widgets/contact_card.dart';
import '../widgets/remaining_slots_card.dart';
import '../widgets/add_contact_sheet.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated || authState.user == null) return const SizedBox.shrink();
        final user = authState.user!;

        return BlocConsumer<ContactsBloc, ContactsState>(
          listener: _blocListener,
          builder: (context, state) {
            return Scaffold(
              appBar: AppHeader(
                title: 'Emergency Setup',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
              body: _buildBody(context, state, user.uid),
            );
          },
        );
      },
    );
  }

  void _blocListener(BuildContext context, ContactsState state) {
    if (state.status == ContactsStatus.error && state.errorMessage != null) {
      AppSnackBar.showError(context, state.errorMessage!);
    } else if (state.status == ContactsStatus.actionSuccess && state.successMessage != null) {
      AppSnackBar.showSuccess(context, state.successMessage!);
    }
  }

  Widget _buildBody(BuildContext context, ContactsState state, String uid) {
    if (state.status == ContactsStatus.initial) {
      context.read<ContactsBloc>().add(LoadContactsEvent(uid));
      return _buildShimmer();
    }

    if (state.status == ContactsStatus.loading) {
      return _buildShimmer();
    }

    if (state.status == ContactsStatus.error && state.contacts.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'Bir hata oluştu',
        onRetry: () => context.read<ContactsBloc>().add(LoadContactsEvent(uid)),
      );
    }

    final contacts = state.contacts;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfo(context),
          AppSpacing.gapHXXl,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              children: [
                ...List.generate(contacts.length, (index) {
                  final contact = contacts[index];
                  return ContactCard(
                    contact: contact,
                    index: index,
                    onEdit: () => _showAddContactSheet(context, uid, contact: contact),
                    onDelete: () => _showDeleteDialog(context, uid, contact),
                  );
                }),
                
                if (contacts.length < AppConstants.maxEmergencyContacts)
                  RemainingSlotsCard(slots: AppConstants.maxEmergencyContacts - contacts.length),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: AppButton(
              label: 'Add New Contact',
              leadingIcon: Icons.add,
              onPressed: () => _showAddContactSheet(context, uid),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms),
          AppSpacing.gapHSm,
          Text(
            'Add up to 5 trusted contacts who will be notified in an emergency.',
            style: theme.textTheme.titleMedium,
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }


  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      itemCount: 3,
      itemBuilder: (_, __) => const Padding(
        padding: AppSpacing.edgeInsetsVSm,
        child: ShimmerContactCard(),
      ),
    );
  }

  void _showAddContactSheet(BuildContext context, String uid, {ContactEntity? contact}) {
    AppBottomSheets.showCustomSheet(
      context: context,
      child: BlocProvider.value(
        value: context.read<ContactsBloc>(),
        child: AddContactSheet(uid: uid, contact: contact),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String uid, ContactEntity contact) async {
    final confirmed = await AppDialogs.showConfirmation(
      context: context,
      title: 'Kontağı Sil',
      message: '${contact.name} acil durum kontağı silinsin mi?',
      confirmText: 'Sil',
      isDestructive: true,
    );
    
    if (confirmed == true && context.mounted) {
      context.read<ContactsBloc>().add(
        DeleteContactEvent(uid: uid, contactId: contact.id),
      );
    }
  }
}
