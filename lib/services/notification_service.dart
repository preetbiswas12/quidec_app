import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'quidec_messages',
      'Quidec Messages',
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showMessageNotification({
    required String sender,
    required String message,
    required String messageId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'quidec_messages',
      'Quidec Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      color: Color.fromARGB(255, 35, 76, 106),
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      messageId.hashCode,
      'Message from $sender',
      message,
      notificationDetails,
      payload: messageId,
    );
  }

  Future<void> showFriendRequestNotification({
    required String sender,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'quidec_requests',
      'Friend Requests',
      channelDescription: 'Notifications for friend requests',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      color: Color.fromARGB(255, 35, 76, 106),
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      sender.hashCode,
      'Friend Request',
      '$sender sent you a friend request',
      notificationDetails,
      payload: sender,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

import 'package:flutter/material.dart';

extension AndroidNotificationDetailsExtension on AndroidNotificationDetails {
  AndroidNotificationDetails copyWith({
    String? channelId,
    String? channelDescription,
    String? channelShowBadge,
    Importance? importance,
    Priority? priority,
    bool? enableLights,
    Color? color,
    bool? enableVibration,
    AndroidSound? sound,
  }) {
    return AndroidNotificationDetails(
      channelId ?? this.channelId,
      channelDescription ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      importance: importance ?? this.importance,
      priority: priority ?? this.priority,
      enableLights: enableLights ?? this.enableLights,
      color: color ?? this.color,
      enableVibration: enableVibration ?? this.enableVibration,
      sound: sound ?? this.sound,
    );
  }
}
