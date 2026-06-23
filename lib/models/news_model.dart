import 'package:cloud_firestore/cloud_firestore.dart';

/// News Model for Kisan Mitra App
/// Represents agriculture news from Firestore
class NewsModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String link;
  final DateTime date;
  final String? source;

  NewsModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.link,
    required this.date,
    this.source,
  });

  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      link: data['link'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: data['source'],
    );
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'link': link,
      'date': Timestamp.fromDate(date),
      'source': source,
    };
  }

  /// Predefined sample news for initial data
  static List<Map<String, dynamic>> get sampleNews => [
    {
      'title': 'MSP Hiked for Kharif Crops 2024-25',
      'imageUrl': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800',
      'description': 'Government announces increased Minimum Support Prices for paddy, cotton, and pulses. Farmers to benefit from higher returns.',
      'link': 'https://www.india.gov.in/',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      'source': 'PIB India',
    },
    {
      'title': 'Monsoon Update: Good Rains Expected This Week',
      'imageUrl': 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800',
      'description': 'IMD predicts widespread rainfall across Maharashtra, Karnataka, and Telangana. Farmers advised to prepare fields.',
      'link': 'https://mausam.imd.gov.in/',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      'source': 'IMD',
    },
    {
      'title': 'Organic Farming Certification Simplified',
      'imageUrl': 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
      'description': 'New guidelines make it easier for small farmers to get organic certification. Reduced fees and faster processing.',
      'link': 'https://pgsindia-ncof.gov.in/',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      'source': 'APEDA',
    },
  ];
}
