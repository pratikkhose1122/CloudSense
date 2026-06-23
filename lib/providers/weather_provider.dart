import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Weather Provider for Kisan Mitra App
/// Manages weather state and location-based fetching
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  bool _locationPermissionDenied = false;

  // Getters
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  bool get locationPermissionDenied => _locationPermissionDenied;

  /// Initialize and fetch weather with GPS
  Future<void> initialize() async {
    await fetchWeatherWithLocation();
  }

  /// Fetch weather using current GPS location
  Future<void> fetchWeatherWithLocation() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Get current position
      final position = await _weatherService.getCurrentPosition();
      
      if (position == null) {
        _locationPermissionDenied = true;
        _error = 'Location permission denied. Please enable location services.';
        _setLoading(false);
        return;
      }
      
      _currentPosition = position;
      _locationPermissionDenied = false;
      
      // Fetch weather for current location
      _weather = await _weatherService.getWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch weather: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    _error = null;
    
    try {
      _weather = await _weatherService.getWeatherByCity(city);
      _error = null;
    } catch (e) {
      _error = 'City not found. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh weather data
  Future<void> refreshWeather() async {
    if (_currentPosition != null) {
      await fetchWeatherWithLocation();
    } else if (_weather != null) {
      await fetchWeatherByCity(_weather!.cityName);
    } else {
      await fetchWeatherWithLocation();
    }
  }

  /// Check if rain is expected
  Future<bool> isRainExpected() async {
    if (_currentPosition == null) return false;
    
    try {
      return await _weatherService.isRainExpected(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
