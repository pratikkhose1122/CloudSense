import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification Service for Kisan Mitra App
/// Handles Firebase Cloud Messaging and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const String _rainAlertChannel = 'rain_alerts';
  static const String _schemeChannel = 'scheme_notifications';
  static const String _newsChannel = 'news_notifications';

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Setup FCM handlers
    _setupFCMHandlers();
    
    // Subscribe to topics
    await _subscribeToTopics();
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel rainChannel = AndroidNotificationChannel(
      _rainAlertChannel,
      'Rain Alerts',
      description: 'Weather alerts for rain predictions',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel schemeChannel = AndroidNotificationChannel(
      _schemeChannel,
      'Government Schemes',
      description: 'New government scheme notifications',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel newsChannel = AndroidNotificationChannel(
      _newsChannel,
      'Agriculture News',
      description: 'Breaking agriculture news updates',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(rainChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(schemeChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(newsChannel);
  }

  /// Setup Firebase Cloud Messaging handlers
  void _setupFCMHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background/terminated message opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    
    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNavigation(data);
    }
  }

  /// Handle notification open (background/terminated)
  void _handleNotificationOpen(RemoteMessage message) {
    print('Notification opened: ${message.notification?.title}');
    _handleNavigation(message.data);
  }

  /// Handle navigation based on notification type
  void _handleNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    
    // Navigation will be handled by the app based on type
    // Types: 'weather', 'scheme', 'news', 'crop'
    print('Navigate to: $type');
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null) {
      String channelId = _newsChannel;
      
      // Determine channel based on message type
      if (message.data['type'] == 'rain') {
        channelId = _rainAlertChannel;
      } else if (message.data['type'] == 'scheme') {
        channelId = _schemeChannel;
      }

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId == _rainAlertChannel 
                ? 'Rain Alerts' 
                : channelId == _schemeChannel 
                    ? 'Government Schemes' 
                    : 'Agriculture News',
            channelDescription: channelId == _rainAlertChannel
                ? 'Weather alerts for rain predictions'
                : channelId == _schemeChannel
                    ? 'New government scheme notifications'
                    : 'Breaking agriculture news updates',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Subscribe to FCM topics
  Future<void> _subscribeToTopics() async {
    await _firebaseMessaging.subscribeToTopic('all_users');
    await _firebaseMessaging.subscribeToTopic('weather_alerts');
    await _firebaseMessaging.subscribeToTopic('agriculture_news');
  }

  /// Subscribe to specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Send rain alert notification (for local testing)
  Future<void> showRainAlert(String location, String time) async {
    await _localNotifications.show(
      0,
      '☔ Rain Alert',
      'Rain expected in $location around $time. Protect your crops!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _rainAlertChannel,
          'Rain Alerts',
          channelDescription: 'Weather alerts for rain predictions',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2E7D32),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({'type': 'rain', 'location': location}),
    );
  }

  /// Send scheme notification (for local testing)
  Future<void> showSchemeNotification(String schemeName) async {
    await _localNotifications.show(
      1,
      '🌾 New Government Scheme',
      '$schemeName is now available. Check eligibility and apply!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _schemeChannel,
          'Government Schemes',
          channelDescription: 'New government scheme notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2E7D32),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({'type': 'scheme', 'name': schemeName}),
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

/// Background message handler (must be top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  // Handle background message
}
