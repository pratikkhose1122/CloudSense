import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/air_quality.dart';
import '../services/air_quality_service.dart';

class AirQualityProvider with ChangeNotifier {
  final AirQualityService _service = AirQualityService();
  AirQuality? _current;
  bool _loading = false;
  String? _error;

  AirQuality? get current => _current;
  bool get loading => _loading;
  String? get error => _error;

  // Cache duration of 30 minutes
  final Duration _cacheDuration = const Duration(minutes: 30);

  Future<void> fetchByCoords(double lat, double lon) async {
    // Try loading from cache first using coordinates as key
    await loadFromCache(lat, lon);
    
    // If we have valid cached data (and not too old), we might want to skip fetch?
    // But usually user pull-to-refresh expects network call.
    // Let's rely on standard flow: load cache (fast), then fetch (fresh).
    // If fetch succeeds, it overwrites cache.
    // If the cache load already established "valid" data, we could skip auto-fetch 
    // but the requirement "Auto-refresh... 15 min" implies we want fresh data.
    // So we'll proceed to fetch.

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.fetchByCoords(lat, lon);
      _current = data;
      await saveToCache(lat, lon, data);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadFromCache(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'aqi_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
      
      if (!prefs.containsKey(key)) return;

      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        
        // Check expiry
        if (map.containsKey('cachedAt')) {
          final savedAt = DateTime.parse(map['cachedAt']);
          if (DateTime.now().difference(savedAt) > _cacheDuration) {
            // Expired, delete and return
            await prefs.remove(key);
            return;
          }
        }

        if (map.containsKey('data')) {
           _current = AirQuality.fromJson(map['data']);
           notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading AQI cache: $e');
    }
  }

  Future<void> saveToCache(double lat, double lon, AirQuality data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'aqi_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
      
      final toSave = jsonEncode({
        'cachedAt': DateTime.now().toIso8601String(),
        'data': data.toJson(),
      });
      
      await prefs.setString(key, toSave);
    } catch (e) {
      print('Error saving AQI cache: $e');
    }
  }

  void clear() {
    _current = null;
    _error = null;
    notifyListeners();
  }
}
