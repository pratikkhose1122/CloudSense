import 'package:cloud_firestore/cloud_firestore.dart';

/// Government Scheme Model for Kisan Mitra App
/// Represents government schemes for farmers from Firestore
class SchemeModel {
  final String id;
  final String name;
  final String overview;
  final String eligibility;
  final String benefits;
  final String applyLink;
  final String? imageUrl;
  final DateTime? lastUpdated;

  SchemeModel({
    required this.id,
    required this.name,
    required this.overview,
    required this.eligibility,
    required this.benefits,
    required this.applyLink,
    this.imageUrl,
    this.lastUpdated,
  });

  factory SchemeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchemeModel(
      id: doc.id,
      name: data['name'] ?? '',
      overview: data['overview'] ?? '',
      eligibility: data['eligibility'] ?? '',
      benefits: data['benefits'] ?? '',
      applyLink: data['applyLink'] ?? '',
      imageUrl: data['imageUrl'],
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      eligibility: json['eligibility'] ?? '',
      benefits: json['benefits'] ?? '',
      applyLink: json['applyLink'] ?? '',
      imageUrl: json['imageUrl'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'overview': overview,
      'eligibility': eligibility,
      'benefits': benefits,
      'applyLink': applyLink,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  /// Predefined sample schemes for initial data
  static List<Map<String, dynamic>> get sampleSchemes => [
    {
      'name': 'PM-KISAN Samman Nidhi',
      'overview': 'Pradhan Mantri Kisan Samman Nidhi is a Central Sector scheme with 100% funding from Government of India. Under the scheme, income support of Rs. 6000/- per year is provided to all farmer families across the country in three equal installments of Rs. 2000/- each every four months.',
      'eligibility': '• All landholding farmer families\n• Small and marginal farmers\n• Farmers with cultivable land\n• Valid bank account and Aadhaar',
      'benefits': '• Rs. 6,000 per year direct benefit transfer\n• Three installments of Rs. 2,000 each\n• Direct transfer to bank account\n• No middlemen involved',
      'applyLink': 'https://pmkisan.gov.in/',
      'imageUrl': 'https://images.unsplash.com/photo-1595855709915-fa457bd60e5a?w=800',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Pradhan Mantri Fasal Bima Yojana',
      'overview': 'PMFBY is an actuarial premium based scheme where farmer pays maximum premium of 2% for Kharif, 1.5% for Rabi food & oilseed crops and 5% for annual commercial/horticultural crops. The balance premium is paid by the Government.',
      'eligibility': '• All farmers growing notified crops\n• Loanee and non-loanee farmers\n• Sharecroppers and tenant farmers\n• Farmers with insurable interest',
      'benefits': '• Comprehensive risk coverage\n• Low premium rates\n• Coverage for yield losses\n• Post-harvest losses covered\n• Localized calamities included',
      'applyLink': 'https://pmfby.gov.in/',
      'imageUrl': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Soil Health Card Scheme',
      'overview': 'Soil Health Card Scheme aims to provide soil health cards to farmers which carry crop-wise recommendations of nutrients and fertilizers required for individual farms. This helps farmers improve productivity through judicious use of inputs.',
      'eligibility': '• All farmers across India\n• Farmers willing to get soil tested\n• Individual farm holdings\n• No land size restriction',
      'benefits': '• Free soil testing\n• Crop-specific recommendations\n• Improved soil health\n• Reduced input costs\n• Higher crop yields\n• Every 3 years renewal',
      'applyLink': 'https://soilhealth.dac.gov.in/',
      'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Kisan Credit Card (KCC)',
      'overview': 'Kisan Credit Card scheme provides farmers with timely access to credit. Farmers can avail short-term loans for cultivation and other agricultural needs at subsidized interest rates.',
      'eligibility': '• Individual farmers\n• Joint borrowers (cultivators)\n• Self-help groups (SHGs)\n• Joint liability groups (JLGs)\n• Tenant farmers',
      'benefits': '• Short-term credit up to Rs. 3 lakh\n• Interest subvention at 2%\n• Prompt repayment incentive of 3%\n• Coverage for post-harvest expenses\n• Maintenance of farm assets\n• Consumption needs of farmer household',
      'applyLink': 'https://www.nabard.org/',
      'imageUrl': 'https://images.unsplash.com/photo-1565514020125-70a5f2f1a5c9?w=800',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'National Mission on Natural Farming',
      'overview': 'Promotes natural farming practices without use of chemical fertilizers and pesticides. Supports farmers in transitioning to sustainable agriculture with financial assistance and training.',
      'eligibility': '• Farmers willing to adopt natural farming\n• Existing organic farmers\n• Farmer producer organizations\n• Self-help groups',
      'benefits': '• Financial assistance for certification\n• Training and capacity building\n• Market linkage support\n• Premium prices for produce\n• Reduced input costs',
      'applyLink': 'https://naturalfarming.dac.gov.in/',
      'imageUrl': 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
  ];
}
