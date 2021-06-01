import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  InitializationSettings init() {
    var androidInitSetting = AndroidInitializationSettings('app_icon');
    return InitializationSettings(android: androidInitSetting, iOS: null);
  }

  NotificationDetails getNotification() {
    var androidNotificationDetails = AndroidNotificationDetails(
        'Channel ID', 'Travel Buddy', 'Application for Travellers',
        importance: Importance.high, ongoing: true);
    return NotificationDetails(android: androidNotificationDetails);
  }
}
