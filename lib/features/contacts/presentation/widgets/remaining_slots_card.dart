import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/dashed_border_container.dart';
import '../../../../core/theme/app_radius.dart';

class RemainingSlotsCard extends StatelessWidget {
  final int slots;

  const RemainingSlotsCard({super.key, required this.slots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DashedBorderContainer(
        color: theme.colorScheme.outline,
        dashWidth: 6,
        dashSpace: 4,
        borderRadius: AppRadius.borderRadiusXl,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppRadius.borderRadiusXl,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt, color: theme.colorScheme.onSurfaceVariant, size: 18),
                AppSpacing.gapWSm,
                Text(
                  '$slots slots remaining',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 250.ms);
  }
}
