import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

/// News Provider for Kisan Mitra App
/// Manages agriculture news state with Firestore
class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NewsModel> get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load news
  Future<void> initialize() async {
    await fetchNews();
  }

  /// Fetch news from Firestore
  Future<void> fetchNews() async {
    _setLoading(true);
    _error = null;
    
    try {
      _news = await _newsService.getNews();
      _error = null;
    } catch (e) {
      _error = 'Failed to load news. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Get news stream for real-time updates
  Stream<List<NewsModel>> getNewsStream() {
    return _newsService.getNewsStream();
  }

  /// Refresh news data
  Future<void> refreshNews() async {
    await fetchNews();
  }

  /// Initialize sample data (for first-time setup)
  Future<void> initializeSampleData() async {
    try {
      await _newsService.initializeSampleData();
      await fetchNews();
    } catch (e) {
      _error = 'Failed to initialize news data.';
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
