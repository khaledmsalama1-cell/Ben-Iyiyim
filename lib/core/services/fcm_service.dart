import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Firebase Cloud Messaging service
/// Handles FCM token management, foreground/background notifications
class FcmService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Logger _logger;

  FcmService(this._messaging, this._localNotifications, this._logger);

  /// Android notification channel for high-priority emergency alerts
  static const AndroidNotificationChannel _emergencyChannel =
      AndroidNotificationChannel(
    AppConstants.fcmChannelId,
    AppConstants.fcmChannelName,
    description: AppConstants.fcmChannelDesc,
    importance: Importance.max,
    enableLights: true,
    enableVibration: true,
    playSound: true,
  );

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Setup local notifications channel (Android)
    await _setupLocalNotificationsChannel();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated tap (notification tap)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle terminated app launch from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _logger.i('FCM initialized successfully');
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // Ensure APNS token is available first on iOS
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) return null;
      }
      return await _messaging.getToken();
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic for receiving broadcasts
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Listen for token refreshes
  Stream<String> get tokenRefreshStream => _messaging.onTokenRefresh;

  // === PRIVATE ===

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.i('FCM permission status: ${settings.authorizationStatus}');
  }

  Future<void> _setupLocalNotificationsChannel() async {
    // Android: create high-priority channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_emergencyChannel);

    // Initialize local notifications plugin
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap while app is in foreground
        _logger.d('Local notification tapped: ${details.payload}');
      },
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.d('Foreground FCM message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // Show as local notification while app is in foreground
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _emergencyChannel.id,
            _emergencyChannel.name,
            channelDescription: _emergencyChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Ben İyiyim Bildirimi',
            color: const Color(0xFFE53935),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['senderId'],
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.d('Notification opened app: ${message.data}');
    // Navigation can be handled here via a stream/notifier
  }
}

/// Top-level FCM background handler (must be top-level or static)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized before using any Firebase services
  // Note: firebase_core.initializeApp() is called in main.dart
}
