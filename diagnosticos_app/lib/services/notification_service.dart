import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const _kEnabledKey = 'notifications_enabled';
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Future<void> init() async {}

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, enabled);
  }
}
