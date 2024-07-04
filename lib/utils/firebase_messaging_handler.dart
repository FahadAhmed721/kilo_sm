import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kiloi_sm/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/screens/home/medias_tab/products_tab/products_tab.dart';
import 'package:kiloi_sm/utils/enums.dart';

class FirebaseMessagingHandler {
  FirebaseMessagingHandler._();

  static AndroidNotificationChannel channel_message =
      const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    importance: Importance.high,
    enableLights: true,
    playSound: true,
  );

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> config() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

// It will be used when there is any message when the app is terminated state
// and user tap on the notification
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        // Now here handle the tap event from a terminated state
        kPrint("initialMessage------");
        kPrint("${initialMessage.data}");
        // You can handle the initial message here if needed.
      }
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
      });
      var initializationSettingsAndroid =
          const AndroidInitializationSettings("@mipmap/ic_launcher");
      var darwinInitializationSettings = const DarwinInitializationSettings();

      LinuxInitializationSettings initializationSettingsLinux =
          const LinuxInitializationSettings(
              defaultActionName: 'Open notification');
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          macOS: darwinInitializationSettings,
          iOS: darwinInitializationSettings,
          linux: initializationSettingsLinux);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: onDidReceiveLocalNotification);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        // Handle the incoming message here in a foreground state.
        if (notification != null && android != null) {
          kPrint("message foreground");
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel_message.id, channel_message.name,
                  // channel_message.description!,
                  icon: android.smallIcon,
                  importance: Importance.high,
                  priority: Priority.high,
                  // other properties...
                ),
              ));
          // _recieveNotification(message);
        }
      });
    } on Exception catch (error) {
      kPrint("error message");
      kPrint(error.toString());
    }
  }

  static Future<void> onDidReceiveLocalNotification(
      NotificationResponse notificationResponse) async {
    // Handle local notification when the user taps on it.
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackground(
      RemoteMessage? message) async {
    kPrint("background data id ${message?.data}");
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (message != null) {}
  }

  static void _handleNotificationTap(RemoteMessage message) {
    kPrint("Notification tapped: ${message.messageId}");
    switch (message.data["type"]) {
      case NotificationType.PRODUCT_NAME:
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (tx) {
            return const ProductTab();
          },
        ));
        break;
    }

    // Here, handle the navigation or specific action based on message data
    // For example:
    // Navigator.pushNamed(context, '/targetScreen', arguments: message.data);
    // Note: Ensure you have access to a BuildContext or use a navigator key
  }

  static Future<void> sendTopicMessage(
      String tokenOrTopic,
      Map<String, dynamic> notificationBody,
      Map<String, dynamic> dataBody) async {
    String serverKey =
        dotenv.env['FIREBASE_SERVER_KEY']!; // Replace with your FCM server key
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final payload = PushNotificationService.constructFCMPayload(
        tokenOrTopic, notificationBody, dataBody);

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 200) {
        kPrint('FCM request sent successfully');
        kPrint('Response body: ${response.body}');
      } else {
        kPrint('FCM request failed with status: ${response.statusCode}');
        kPrint('Response body: ${response.body}');
      }
    } catch (e) {
      kPrint('An error occurred while sending FCM request: $e');
    }
  }
}

class PushNotificationService {
  static int _messageCount = 0;

  // This method constructs the payload for the FCM message.
  static String constructFCMPayload(String? token,
      Map<String, dynamic> notificationBody, Map<String, dynamic> dataBody) {
    _messageCount++; // Increment the message count

    // Create the payload as a Map
    Map<String, dynamic> payload = {
      'to': token, // 'to' field is the FCM token of the target device
      'data': dataBody,
      'notification': notificationBody,
      // If needed, you can also add Android or iOS specific options
      'android': {
        'importance': 'high',
        'priority': 'high', // Set priority to high on Android
      },
      'apns': {
        'headers': {
          'apns-priority': '5', // Set priority on iOS
        },
        'payload': {
          'aps': {
            'sound': 'default', // Set default sound for iOS
          },
        },
      },
    };

    // Convert the Map to a JSON string
    return jsonEncode(payload);
  }

  // Constructor, other methods, etc.
}
