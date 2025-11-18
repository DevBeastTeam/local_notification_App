import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Web Notifications
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// -----------------------------
/// Professional Notification Service
/// -----------------------------
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize notifications
  Future<void> init() async {
    if (kIsWeb) {
      _requestWebPermission();
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android Notification Channel
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important notifications with alerts',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// -----------------------------
  /// Mobile + Web Notifications
  /// -----------------------------

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Web notification
    if (kIsWeb) {
      _showWebNotification(title, body);
      _showInAppBanner(title, body);
      return;
    }

    // Mobile notification
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
    _showInAppBanner(title, body); // Animated in-app banner
  }

  /// Show a notification with BigText style
  Future<void> showBigTextNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
  }) async {
    if (kIsWeb) {
      _showWebNotification(title, '$body\n\n$bigText');
      _showInAppBanner(title, '$body\n$bigText');
      return;
    }

    final bigTextStyle = BigTextStyleInformation(bigText);

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      styleInformation: bigTextStyle,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
    _showInAppBanner(title, '$body\n$bigText');
  }

  /// Schedule mobile-only notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) {
      _showWebNotification(title, 'Scheduling not supported on Web.');
      _showInAppBanner(title, 'Scheduling not supported on Web.');
      return;
    }

    await (
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Cancel all mobile notifications
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// -----------------------------
  /// Private Helpers
  /// -----------------------------

  void _requestWebPermission() {
    html.Notification.requestPermission().then((result) {
      debugPrint('Web Notification Permission: $result');
    });
  }

  void _showWebNotification(String title, String body) {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body, icon: 'icons/Icon-192.png');
    } else {
      _requestWebPermission();
    }
  }

  /// Animated in-app banner (mobile + web)
  void _showInAppBanner(String title, String body) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(body, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // You can navigate to specific page using navigatorKey
  }
}
