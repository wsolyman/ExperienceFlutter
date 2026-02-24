import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@android:drawable/ic_dialog_info');
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request permission
    await _requestPermission();

    // Get FCM token
    await _getToken();

    // Setup message handlers
    _setupMessageHandlers();
    print("🔔 Notifications initialized");
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    SharedPreferences userpref = await SharedPreferences.getInstance();
    userpref.setString("fcmToken", token.toString());
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');

    });
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Foreground message received');
      await _saveNotification(message);
      await _showLocalNotification(message);
    });

    // Background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('App opened from background notification');
      await _saveNotification(message);
      await _markNotificationAsRead(message);

    });

    // Terminated state messages
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        print('App opened from terminated state notification');
        await _saveNotification(message);
        await _markNotificationAsRead(message);
      }
    });
  }
  Future<void> _saveNotification(RemoteMessage message) async {
    try {
      final notification = Notification(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? '',
        data: message.data,
        imageUrl: message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
        category: message.data['category'],
      );

      await _dbHelper.insertNotification(notification);
      print('Notification saved to database');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<void> _markNotificationAsRead(RemoteMessage message) async {
    // You'll need to implement logic to find and mark the notification
    // This is a simplified version
    print('Marking notification as read');
  }

  // Public methods to access database
  Future<List<Notification>> getNotifications() async {
    return await _dbHelper.getAllNotifications();
  }

  Future<int> getUnreadCount() async {
    return await _dbHelper.getUnreadCount();
  }

  Future<void> markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _dbHelper.markAllAsRead();
  }

  Future<void> deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
  }

  Future<void> clearAllNotifications() async {
    await _dbHelper.clearAllNotifications();
  }
}