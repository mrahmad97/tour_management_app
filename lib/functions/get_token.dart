import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tour_management_app/main.dart';


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
  final data = message.data;
  final type = data['type'];

  // Navigate based on the notification type
  if (type == 'route') {
    NavigationService.navigatorKey.currentState?.pushNamed(
      '/routeDetails',
      arguments: data,
    );
  } else if (type == 'groupMember') {
    NavigationService.navigatorKey.currentState?.pushNamed(
      '/groupDetails',
      arguments: data,
    );
  } else if (type == 'chat') {
    NavigationService.navigatorKey.currentState?.pushNamed(
      '/chat',
      arguments: data,
    );
  } else {
    print('Unknown notification type: $type');
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notification',
      description: 'This channel is used for important notifications',
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    final data = message.data;
    final type = data['type'];

    // Navigate based on the notification type
    if (type == 'route') {
       NavigationService.navigatorKey.currentState?.pushNamed(
         '/routeDetails',
         arguments: data,
       );
     } else if (type == 'groupMember') {
      NavigationService.navigatorKey.currentState?.pushNamed(
         '/groupDetails',
         arguments: data,
       );
     } else if (type == 'chat') {
      NavigationService.navigatorKey.currentState?.pushNamed(
         '/chat',
         arguments: data,
       );
     } else {
       print('Unknown notification type: $type');
     }
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const setting = InitializationSettings(android: android);

    await _localNotifications.initialize(
      setting,
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    final String vapidKey = 'BPqTv_sCppZMG_4OAnKKNvfYGfwBkLJoILPfkA8PCswvAGMaE78oyDEk6H2krpFSu42bIUBbWV7zOn_TirGdZ5A';
    if (kIsWeb) {
      // Web-specific setup
      await FirebaseMessaging.instance.getToken(vapidKey: vapidKey); // Replace with your actual VAPID key
      FirebaseMessaging.onMessage.listen((message) {
        // Handle foreground messages for web
        print('Web: Received a foreground message');
        print('Message data: $message');

      });
    } else {
      // Mobile-specific setup
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      });
    }
  }


  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();
    print('Token: $FCMToken');
    initPushNotifications();
    initLocalNotifications();
  }
}
