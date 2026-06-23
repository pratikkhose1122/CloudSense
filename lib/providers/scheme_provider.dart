import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../services/scheme_service.dart';

/// Government Scheme Provider for Kisan Mitra App
/// Manages government scheme state with Firestore
class SchemeProvider extends ChangeNotifier {
  final SchemeService _schemeService = SchemeService();
  
  List<SchemeModel> _schemes = [];
  SchemeModel? _selectedScheme;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SchemeModel> get schemes => _schemes;
  SchemeModel? get selectedScheme => _selectedScheme;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load schemes
  Future<void> initialize() async {
    await fetchSchemes();
  }

  /// Fetch schemes from Firestore
  Future<void> fetchSchemes() async {
    _setLoading(true);
    _error = null;
    
    try {
      _schemes = await _schemeService.getSchemes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load schemes. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Get schemes stream for real-time updates
  Stream<List<SchemeModel>> getSchemesStream() {
    return _schemeService.getSchemesStream();
  }

  /// Select a scheme for detail view
  void selectScheme(SchemeModel scheme) {
    _selectedScheme = scheme;
    notifyListeners();
  }

  /// Clear selected scheme
  void clearSelectedScheme() {
    _selectedScheme = null;
    notifyListeners();
  }

  /// Search schemes
  Future<void> searchSchemes(String query) async {
    if (query.isEmpty) {
      await fetchSchemes();
      return;
    }

    _setLoading(true);
    _error = null;
    
    try {
      _schemes = await _schemeService.searchSchemes(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to search schemes.';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh schemes data
  Future<void> refreshSchemes() async {
    await fetchSchemes();
  }

  /// Initialize sample data (for first-time setup)
  Future<void> initializeSampleData() async {
    try {
      await _schemeService.initializeSampleData();
      await fetchSchemes();
    } catch (e) {
      _error = 'Failed to initialize scheme data.';
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
