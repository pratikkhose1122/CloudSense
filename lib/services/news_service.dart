import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

/// News Service for Kisan Mitra App
/// Handles agriculture news data from Firestore
class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'news';

  /// Get stream of news for real-time updates
  Stream<List<NewsModel>> getNewsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList();
    });
  }

  /// Get news as future (one-time fetch)
  Future<List<NewsModel>> getNews() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => NewsModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  /// Add a new news item (for admin use)
  Future<void> addNews(NewsModel news) async {
    try {
      await _firestore.collection(_collection).add(news.toJson());
    } catch (e) {
      throw Exception('Failed to add news: $e');
    }
  }

  /// Update news item (for admin use)
  Future<void> updateNews(String id, NewsModel news) async {
    try {
      await _firestore.collection(_collection).doc(id).update(news.toJson());
    } catch (e) {
      throw Exception('Failed to update news: $e');
    }
  }

  /// Delete news item (for admin use)
  Future<void> deleteNews(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete news: $e');
    }
  }

  /// Initialize sample news data (run once during setup)
  Future<void> initializeSampleData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      
      // Only add if collection is empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        for (var newsData in NewsModel.sampleNews) {
          final docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, newsData);
        }
        
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to initialize news data: $e');
    }
  }
}
