import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../services/push_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _enabled = false;
  bool _aqiEnabled = true;
  bool _weatherEnabled = true;
  int _frequencyMinutes = 60;

  bool get enabled => _enabled;
  bool get aqiEnabled => _aqiEnabled;
  bool get weatherEnabled => _weatherEnabled;
  int get frequencyMinutes => _frequencyMinutes;

  NotificationProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('notif_enabled') ?? false;
    _aqiEnabled = prefs.getBool('notif_aqi') ?? true;
    _weatherEnabled = prefs.getBool('notif_weather') ?? true;
    _frequencyMinutes = prefs.getInt('notif_freq_mins') ?? 60;
    
    // Sync topics on load
    _syncTopics();
    
    notifyListeners();
  }

  Future<void> saveSettings({
    required bool enabled,
    required bool aqiEnabled,
    required bool weatherEnabled,
    required int frequencyMinutes,
  }) async {
    _enabled = enabled;
    _aqiEnabled = aqiEnabled;
    _weatherEnabled = weatherEnabled;
    _frequencyMinutes = frequencyMinutes;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', enabled);
    await prefs.setBool('notif_aqi', aqiEnabled);
    await prefs.setBool('notif_weather', weatherEnabled);
    await prefs.setInt('notif_freq_mins', frequencyMinutes);

    _syncTopics();

    if (enabled) {
      scheduleBackgroundTask();
    } else {
      cancelBackgroundTask();
    }
  }

  Future<void> _syncTopics() async {
    final service = PushNotificationService();
    if (_enabled) {
      if (_aqiEnabled) {
         await service.subscribeToTopic('aqi_alerts');
      } else {
         await service.unsubscribeFromTopic('aqi_alerts');
      }

      if (_weatherEnabled) {
         await service.subscribeToTopic('weather_updates');
      } else {
         await service.unsubscribeFromTopic('weather_updates');
      }
    } else {
      await service.unsubscribeFromTopic('aqi_alerts');
      await service.unsubscribeFromTopic('weather_updates');
    }
  }

  void scheduleBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "cloudsense_periodic_task",
      "cloudsenseFetch",
      frequency: Duration(minutes: _frequencyMinutes),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
          networkType: NetworkType.connected,
      )
    );
  }

  void cancelBackgroundTask() {
    Workmanager().cancelByUniqueName("cloudsense_periodic_task");
  }

  // Debug helper
  Future<void> triggerTestNotification() async {
      // This will be called from UI to test immediate notification
      // Logic handled in UI or via service directly for test
  }
}
