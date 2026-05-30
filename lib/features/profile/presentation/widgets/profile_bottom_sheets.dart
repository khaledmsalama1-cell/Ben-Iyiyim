import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/sheets/app_bottom_sheets.dart';

class ProfileBottomSheets {
  ProfileBottomSheets._();

  static void showNotificationsConfig(BuildContext context) {
    AppBottomSheets.showCustomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapHLg,
            SwitchListTile(
              title: const Text('Emergency Sounds', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Play loud siren sound for critical alerts'),
              value: true,
              onChanged: (_) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Vibrate device on status updates'),
              value: true,
              onChanged: (_) {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  static void showSafetySettingsConfig(BuildContext context) {
    AppBottomSheets.showCustomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapHLg,
            ListTile(
              title: const Text('SOS Countdown Timer', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('10 seconds'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: () {},
            ),
            ListTile(
              title: const Text('Location Sharing Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Real-time during alerts'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  static void showHelpSupportConfig(BuildContext context) {
    AppBottomSheets.showCustomSheet(
      context: context,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Text(
              'Help & Support',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapHLg,
            const Text(
              'How to use Ben İyiyim:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            AppSpacing.gapHSm,
            const Text(
              '1. Set up emergency contacts under the Contacts tab.\n'
              '2. In an emergency, press and hold the SOS button on the home tab for 2 seconds.\n'
              '3. Select your safety status (Safe, Need Help, Injured).\n'
              '4. Your location and status will be broadcasted to your primary contacts.\n'
              '5. Keep the app active to send continuous GPS signals.',
              style: TextStyle(height: 1.5),
            ),
            AppSpacing.gapHXXl,
            const Text(
              'Frequently Asked Questions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            AppSpacing.gapHSm,
            const Text(
              'Q: Does the app work offline?\n'
              'A: Yes, status changes are cached locally and synced automatically as soon as internet connection is restored.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  static void showSecurityConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security & Credentials', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Security policies, password updates, and biometric login setup are automatically managed by Google Sign-In & Firebase Auth.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
