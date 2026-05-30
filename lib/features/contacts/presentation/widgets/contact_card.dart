import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/contact_entity.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class ContactCard extends StatelessWidget {
  final ContactEntity contact;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = index == 0;
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: AppSpacing.edgeInsetsAllLg,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: AppTextStyles.titleLarge.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          AppSpacing.gapWLg,
          
          // Info text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.gapHXs,
                if (isPrimary)
                  Row(
                    children: [
                      Icon(Icons.star, color: theme.colorScheme.tertiary, size: 14),
                      AppSpacing.gapWXs,
                      Text(
                        'Primary Contact',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Secondary',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: 0.05);
  }
}
