import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheme_model.dart';

/// Government Scheme Service for Kisan Mitra App
/// Handles government scheme data from Firestore
class SchemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'schemes';

  /// Get stream of schemes for real-time updates
  Stream<List<SchemeModel>> getSchemesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SchemeModel.fromFirestore(doc)).toList();
    });
  }

  /// Get schemes as future (one-time fetch)
  Future<List<SchemeModel>> getSchemes() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => SchemeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch schemes: $e');
    }
  }

  /// Get single scheme by ID
  Future<SchemeModel?> getSchemeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return SchemeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch scheme: $e');
    }
  }

  /// Add a new scheme (for admin use)
  Future<void> addScheme(SchemeModel scheme) async {
    try {
      await _firestore.collection(_collection).add(scheme.toJson());
    } catch (e) {
      throw Exception('Failed to add scheme: $e');
    }
  }

  /// Update scheme (for admin use)
  Future<void> updateScheme(String id, SchemeModel scheme) async {
    try {
      await _firestore.collection(_collection).doc(id).update(scheme.toJson());
    } catch (e) {
      throw Exception('Failed to update scheme: $e');
    }
  }

  /// Delete scheme (for admin use)
  Future<void> deleteScheme(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete scheme: $e');
    }
  }

  /// Search schemes by name
  Future<List<SchemeModel>> searchSchemes(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      final schemes = snapshot.docs
          .map((doc) => SchemeModel.fromFirestore(doc))
          .where((scheme) => 
              scheme.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return schemes;
    } catch (e) {
      throw Exception('Failed to search schemes: $e');
    }
  }

  /// Initialize sample scheme data (run once during setup)
  Future<void> initializeSampleData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      
      // Only add if collection is empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        for (var schemeData in SchemeModel.sampleSchemes) {
          final docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, schemeData);
        }
        
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to initialize scheme data: $e');
    }
  }
}
