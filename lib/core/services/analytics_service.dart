import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics wrapper for tracking user behavior
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // === USER ===

  Future<void> setUserId(String uid) async {
    await _analytics.setUserId(id: uid);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
  }

  // === EVENTS ===

  Future<void> logLogin({String method = 'email'}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({String method = 'email'}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logEmergencyStatusSent() async {
    await _analytics.logEvent(name: 'emergency_status_sent', parameters: {
      'method': 'online',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logSmsFallback(int contactCount) async {
    await _analytics.logEvent(name: 'sms_fallback_triggered', parameters: {
      'contact_count': contactCount,
    });
  }

  Future<void> logContactAdded() async {
    await _analytics.logEvent(name: 'emergency_contact_added');
  }

  Future<void> logContactDeleted() async {
    await _analytics.logEvent(name: 'emergency_contact_deleted');
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logNotificationReceived(String type) async {
    await _analytics.logEvent(
        name: 'notification_received', parameters: {'type': type});
  }
}
