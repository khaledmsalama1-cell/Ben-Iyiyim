// App-wide constants for Ben İyiyim
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Ben İyiyim';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Depremde güvende olduğunu bildirmek için tek dokunuş';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String contactsCollection = 'contacts';
  static const String statusesCollection = 'statuses';
  static const String notificationsCollection = 'notifications';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';
  static const String fcmTokenKey = 'fcm_token';

  // FCM
  static const String fcmChannelId = 'ben_iyiyim_emergency';
  static const String fcmChannelName = 'Acil Durum Bildirimleri';
  static const String fcmChannelDesc = 'Yakınlarınızdan gelen acil durum bildirimleri';

  // Limits
  static const int maxEmergencyContacts = 5;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;

  // SMS
  static const String defaultSmsMessage =
      'Ben İyiyim! Depremden etkilenmedim, merak etmeyin. - Ben İyiyim Uygulaması';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration pulseAnimation = Duration(seconds: 2);
}
