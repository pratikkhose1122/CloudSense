import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../services/crop_service.dart';

/// Crop Provider for Kisan Mitra App
/// Manages crop information state with Firestore
class CropProvider extends ChangeNotifier {
  final CropService _cropService = CropService();
  
  List<CropModel> _crops = [];
  CropModel? _selectedCrop;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CropModel> get crops => _crops;
  CropModel? get selectedCrop => _selectedCrop;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load crops
  Future<void> initialize() async {
    await fetchCrops();
  }

  /// Fetch crops from Firestore
  Future<void> fetchCrops() async {
    _setLoading(true);
    _error = null;
    
    try {
      _crops = await _cropService.getCrops();
      _error = null;
    } catch (e) {
      _error = 'Failed to load crops. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Get crops stream for real-time updates
  Stream<List<CropModel>> getCropsStream() {
    return _cropService.getCropsStream();
  }

  /// Select a crop for detail view
  void selectCrop(CropModel crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  /// Clear selected crop
  void clearSelectedCrop() {
    _selectedCrop = null;
    notifyListeners();
  }

  /// Search crops
  Future<void> searchCrops(String query) async {
    if (query.isEmpty) {
      await fetchCrops();
      return;
    }

    _setLoading(true);
    _error = null;
    
    try {
      _crops = await _cropService.searchCrops(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to search crops.';
    } finally {
      _setLoading(false);
    }
  }

  /// Get crops by season
  Future<void> getCropsBySeason(String season) async {
    _setLoading(true);
    _error = null;
    
    try {
      _crops = await _cropService.getCropsBySeason(season);
      _error = null;
    } catch (e) {
      _error = 'Failed to load crops for $season.';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh crops data
  Future<void> refreshCrops() async {
    await fetchCrops();
  }

  /// Initialize sample data (for first-time setup)
  Future<void> initializeSampleData() async {
    try {
      await _cropService.initializeSampleData();
      await fetchCrops();
    } catch (e) {
      _error = 'Failed to initialize crop data.';
      notifyListeners();
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
