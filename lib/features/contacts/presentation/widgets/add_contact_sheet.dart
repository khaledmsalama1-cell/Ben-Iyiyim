import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/forms/app_text_field.dart';
import '../../domain/entities/contact_entity.dart';
import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';

class AddContactSheet extends StatefulWidget {
  final String uid;
  final ContactEntity? contact;

  const AddContactSheet({super.key, required this.uid, this.contact});

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _relationship = 'Family';

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+90 ### ### ## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    if (widget.contact != null) {
      _relationship = widget.contact!.relationship ?? 'Family';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;
    
    if (isEditing) {
      context.read<ContactsBloc>().add(
        UpdateContactEvent(
          uid: widget.uid,
          contact: widget.contact!.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            relationship: _relationship,
          ),
        ),
      );
    } else {
      context.read<ContactsBloc>().add(
        AddContactEvent(
          uid: widget.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          relationship: _relationship,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactsBloc, ContactsState>(
      listener: (context, state) {
        if (state.status == ContactsStatus.actionSuccess) {
          context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state.status == ContactsStatus.adding;
        
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Contact' : 'Add New Contact',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppSpacing.gapHXXl,
                AppTextField(
                  label: 'Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'İsim gerekli' : null,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapHLg,
                AppTextField(
                  label: 'Email (Optional)',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapHLg,
                AppTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  validator: (v) => v == null || v.trim().isEmpty ? 'Telefon gerekli' : null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onSave(),
                ),
                AppSpacing.gapHXXXL,
                AppButton(
                  label: isEditing ? 'Save Changes' : 'Add Contact',
                  leadingIcon: isEditing ? Icons.save_outlined : Icons.add,
                  onPressed: _onSave,
                  isLoading: isLoading,
                  style: AppButtonStyle.primary,
                ),
                AppSpacing.gapHSm,
              ],
            ),
          ),
        );
      },
    );
  }
}
