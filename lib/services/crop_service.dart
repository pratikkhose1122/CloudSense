import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_model.dart';

/// Crop Service for Kisan Mitra App
/// Handles crop information data from Firestore
class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'crops';

  /// Get stream of crops for real-time updates
  Stream<List<CropModel>> getCropsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CropModel.fromFirestore(doc)).toList();
    });
  }

  /// Get crops as future (one-time fetch)
  Future<List<CropModel>> getCrops() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => CropModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch crops: $e');
    }
  }

  /// Get single crop by ID
  Future<CropModel?> getCropById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return CropModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch crop: $e');
    }
  }

  /// Add a new crop (for admin use)
  Future<void> addCrop(CropModel crop) async {
    try {
      await _firestore.collection(_collection).add(crop.toJson());
    } catch (e) {
      throw Exception('Failed to add crop: $e');
    }
  }

  /// Update crop (for admin use)
  Future<void> updateCrop(String id, CropModel crop) async {
    try {
      await _firestore.collection(_collection).doc(id).update(crop.toJson());
    } catch (e) {
      throw Exception('Failed to update crop: $e');
    }
  }

  /// Delete crop (for admin use)
  Future<void> deleteCrop(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete crop: $e');
    }
  }

  /// Search crops by name
  Future<List<CropModel>> searchCrops(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      final crops = snapshot.docs
          .map((doc) => CropModel.fromFirestore(doc))
          .where((crop) => 
              crop.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return crops;
    } catch (e) {
      throw Exception('Failed to search crops: $e');
    }
  }

  /// Get crops by season (based on sowing time)
  Future<List<CropModel>> getCropsBySeason(String season) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .get();
      
      final crops = snapshot.docs
          .map((doc) => CropModel.fromFirestore(doc))
          .where((crop) => 
              crop.sowingTime.toLowerCase().contains(season.toLowerCase()))
          .toList();
      
      return crops;
    } catch (e) {
      throw Exception('Failed to fetch crops by season: $e');
    }
  }

  /// Initialize sample crop data (run once during setup)
  Future<void> initializeSampleData() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      
      // Only add if collection is empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        for (var cropData in CropModel.sampleCrops) {
          final docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, cropData);
        }
        
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to initialize crop data: $e');
    }
  }
}
