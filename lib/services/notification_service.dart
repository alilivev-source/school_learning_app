import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// خدمة الإشعارات المحلية: تذكير الطفل بالتدرّب يومياً
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    try {
      await _plugin.initialize(settings);
      _isInitialized = true;
    } catch (_) {
      // تجاهل الخطأ إن لم تتوفر منصة الإشعارات
    }
  }

  /// إرسال إشعار فوري (اختبار أو تنبيه إنجاز)
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_isInitialized) await init();
    const androidDetails = AndroidNotificationDetails(
      'rawdat_al_noor_channel',
      'روضة النور',
      channelDescription: 'إشعارات تطبيق روضة النور',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    try {
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // تجاهل الخطأ
    }
  }

  /// جدولة تذكير يومي بالتدرّب (يتطلب حزمة timezone لضبط الوقت الفعلي؛
  /// هنا نكتفي بإشعار فوري بسيط كتنبيه ترحيبي عند تفعيل الميزة)
  Future<void> scheduleDailyReminder({
    TimeOfDay time = const TimeOfDay(hour: 17, minute: 0),
  }) async {
    await showInstant(
      title: '📚 حان وقت التعلم!',
      body: 'تعال نتدرب على الحروف والكلمات في روضة النور 🌙',
      id: 1,
    );
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // تجاهل الخطأ
    }
  }
}
