import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  Future<void> initialize() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // طلب الإذن
      status = await Permission.notification.request();
    }

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }


  Future<void> showBackgroundNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'radar_channel',
      'Radar Alerts',
      channelDescription: 'Notifications for nearby speed radars',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      ongoing: true,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}