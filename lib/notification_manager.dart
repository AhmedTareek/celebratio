import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'acess_tokens.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}, '
      '${message.notification?.body}, ${message.data}');
}

class NotificationManager {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static const _androidNotificationChannel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize Firebase Messaging and request notification permissions
  static Future<void> initialize() async {
    var response = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // check if the user granted permission
    if (response.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }else {
      print('User declined or has not accepted permission');
    }

    // Initialize the local notifications plugin
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(settings);

    final platform =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidNotificationChannel);

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}, '
          '${message.notification?.body}, ${message.data}');
      final notification = message.notification;
      if (notification == null) return;
      _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidNotificationChannel.id,
              _androidNotificationChannel.name,
              channelDescription: _androidNotificationChannel.description,
              importance: _androidNotificationChannel.importance,
            ),
          ),
          payload: jsonEncode(message.data));
    });

    // Handle messages when the app is in the background
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

    print('FCM initialized');
  }


  // Get the device token
  // this class is not pushed to the repo because it contains sensitive information
  // as the private key of the service account
  static Future<String?> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('Device Token: $token');
      return token;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  // Send a notification to a specific device
  // Send a notification to a specific device using FCM v1 API
  static Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
  })
  async {
    const String projectId = 'celebratio-1a894';

    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
    final accessToken = await AccessTokenFirebase().getAccessToken();
    print("targetToken: $targetToken");
    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'token': targetToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'priority': 'HIGH',
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
