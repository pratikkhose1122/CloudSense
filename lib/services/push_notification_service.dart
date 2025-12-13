import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Stream to handle deep link actions (e.g. 'aqi', 'weather')
  final _actionController = StreamController<String>.broadcast();
  Stream<String> get actionStream => _actionController.stream;

  Future<void> initialize() async {
    // 1. Request Permission
    await requestPermission();

    // 2. Init Local Notifications
    await _initLocalNotifications();

    // 3. Handle Token
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
      // TODO: Send to backend
    });

    // 4. Topics (Default subscriptions)
    await subscribeToTopic("aqi_alerts");
    await subscribeToTopic("weather_updates");

    // 5. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground Message: ${message.data}");
      _showLocalNotification(message);
    });

    // 6. Background/Terminated Message Handler (Deep Linking)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification Clicked (Background): ${message.data}");
      _handleDeepLink(message.data);
    });

    // Check if app was opened from a terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("App Opened from Terminated: ${initialMessage.data}");
      _handleDeepLink(initialMessage.data);
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle foreground notification tap
        debugPrint("Foreground Notification Tapped: ${response.payload}");
        if (response.payload != null) {
          // Parse payload if it's a JSON string or just handle types
          // For simplicity, assuming payload is the 'type'
          // In _showLocalNotification, we'll set payload.
           _actionController.add(response.payload!);
        }
      },
    );
    
    // Create Channel for Android
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'cloudsense_updates', // id
            'CloudSense Updates', // title
            description: 'Weather & AQI real-time alerts',
            importance: Importance.high,
          ));
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    if (notification != null && android != null) {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cloudsense_updates',
            'CloudSense Updates',
            channelDescription: 'Weather & AQI real-time alerts',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: data['type'], 
      );
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      _actionController.add(data['type']);
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cloudsense_updates',
      'CloudSense Updates',
      channelDescription: 'Weather & AQI real-time alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint("Subscribed to $topic");
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint("Unsubscribed from $topic");
  }
}
