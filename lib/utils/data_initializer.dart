import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';
import '../models/scheme_model.dart';
import '../models/crop_model.dart';

/// Data Initializer Utility
/// Helps initialize Firestore with sample data
class DataInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize all collections with sample data
  Future<void> initializeAllData() async {
    await initializeNews();
    await initializeSchemes();
    await initializeCrops();
  }

  /// Initialize news collection
  Future<void> initializeNews() async {
    final collection = _firestore.collection('news');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      final batch = _firestore.batch();
      
      for (var data in NewsModel.sampleNews) {
        final docRef = collection.doc();
        batch.set(docRef, data);
      }
      
      await batch.commit();
      print('News data initialized');
    }
  }

  /// Initialize schemes collection
  Future<void> initializeSchemes() async {
    final collection = _firestore.collection('schemes');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      final batch = _firestore.batch();
      
      for (var data in SchemeModel.sampleSchemes) {
        final docRef = collection.doc();
        batch.set(docRef, data);
      }
      
      await batch.commit();
      print('Schemes data initialized');
    }
  }

  /// Initialize crops collection
  Future<void> initializeCrops() async {
    final collection = _firestore.collection('crops');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      final batch = _firestore.batch();
      
      for (var data in CropModel.sampleCrops) {
        final docRef = collection.doc();
        batch.set(docRef, data);
      }
      
      await batch.commit();
      print('Crops data initialized');
    }
  }

  /// Clear all data (use with caution)
  Future<void> clearAllData() async {
    await _clearCollection('news');
    await _clearCollection('schemes');
    await _clearCollection('crops');
  }

  /// Clear a specific collection
  Future<void> _clearCollection(String collectionName) async {
    final collection = _firestore.collection(collectionName);
    final snapshot = await collection.get();
    
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('$collectionName cleared');
  }
}
