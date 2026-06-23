import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/push_notification_service.dart';
import '../services/smart_notification_logic.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Initialize dependencies
    await dotenv.load(fileName: ".env");
    final notificationService = PushNotificationService();
    await notificationService.initialize(); 

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 2. Check settings
      final enabled = prefs.getBool('notif_enabled') ?? false;
      if (!enabled) return Future.value(true);

      final aqiEnabled = prefs.getBool('notif_aqi') ?? true;
      final weatherEnabled = prefs.getBool('notif_weather') ?? true;
      final dailySummary = prefs.getBool('notif_daily_summary') ?? true;
      final severeOnly = prefs.getBool('notif_severe_only') ?? false;

      // 3. Get Last Location
      final lat = prefs.getDouble('last_lat');
      final lon = prefs.getDouble('last_lon');

      if (lat == null || lon == null) {
        // print("No location stored for background task.");
        return Future.value(true);
      }

      // 4. Run Smart Logic
      await SmartNotificationLogic(prefs).checkUpdates(
        lat: lat,
        lon: lon,
        aqiEnabled: aqiEnabled,
        weatherEnabled: weatherEnabled,
        dailySummaryEnabled: dailySummary,
        severeAlertsOnly: severeOnly,
      );
      
    } catch (e) {
      // print('Background task error: $e');
      return Future.value(false);
    }

    return Future.value(true);
  });
}
