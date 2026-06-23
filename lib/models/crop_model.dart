import 'package:cloud_firestore/cloud_firestore.dart';

/// Crop Model for Kisan Mitra App
/// Represents crop information and farming guidance from Firestore
class CropModel {
  final String id;
  final String name;
  final String imageUrl;
  final String sowingTime;
  final String irrigation;
  final String fertilizer;
  final String pestControl;
  final String harvestTime;
  final String? climate;
  final String? soilType;
  final String? varieties;
  final String? marketPrice;
  final DateTime? lastUpdated;

  CropModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sowingTime,
    required this.irrigation,
    required this.fertilizer,
    required this.pestControl,
    required this.harvestTime,
    this.climate,
    this.soilType,
    this.varieties,
    this.marketPrice,
    this.lastUpdated,
  });

  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sowingTime: data['sowingTime'] ?? '',
      irrigation: data['irrigation'] ?? '',
      fertilizer: data['fertilizer'] ?? '',
      pestControl: data['pestControl'] ?? '',
      harvestTime: data['harvestTime'] ?? '',
      climate: data['climate'],
      soilType: data['soilType'],
      varieties: data['varieties'],
      marketPrice: data['marketPrice'],
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sowingTime: json['sowingTime'] ?? '',
      irrigation: json['irrigation'] ?? '',
      fertilizer: json['fertilizer'] ?? '',
      pestControl: json['pestControl'] ?? '',
      harvestTime: json['harvestTime'] ?? '',
      climate: json['climate'],
      soilType: json['soilType'],
      varieties: json['varieties'],
      marketPrice: json['marketPrice'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'sowingTime': sowingTime,
      'irrigation': irrigation,
      'fertilizer': fertilizer,
      'pestControl': pestControl,
      'harvestTime': harvestTime,
      'climate': climate,
      'soilType': soilType,
      'varieties': varieties,
      'marketPrice': marketPrice,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  /// Predefined sample crops for initial data
  static List<Map<String, dynamic>> get sampleCrops => [
    {
      'name': 'Sugarcane',
      'imageUrl': 'https://images.unsplash.com/photo-1595408076683-5d0c523c0386?w=800',
      'sowingTime': 'February to March (Spring planting)\nJuly to August (Autumn planting)\n\nBest time: Before monsoon for rain-fed areas',
      'irrigation': '• Total water requirement: 2000-2500 mm\n• Critical stages: Germination, tillering, grand growth\n• Method: Furrow irrigation recommended\n• Frequency: Every 7-10 days in summer\n• Avoid waterlogging - ensure proper drainage',
      'fertilizer': '• Nitrogen: 250-300 kg/ha (split in 3 doses)\n• Phosphorus: 100-125 kg P2O5/ha\n• Potassium: 100-125 kg K2O/ha\n• Apply FYM: 25-30 tonnes/ha at planting\n• Micronutrients: Zinc, Iron as needed',
      'pestControl': '• Early shoot borer: Use resistant varieties\n• Top borer: Biological control with Trichogramma\n• White grub: Apply neem cake @ 200 kg/ha\n• Mealy bug: Spray neem oil or imidacloprid\n• Rat management: Use zinc phosphide baits',
      'harvestTime': '• Harvest when sucrose content is maximum\n• Age: 10-12 months for planting crop\n• Age: 12-16 months for ratoon crop\n• Signs: Lower leaves turn yellow, internodes mature\n• Harvest during dry weather',
      'climate': 'Tropical climate with temperature 20-35°C. Requires abundant sunshine and moderate rainfall.',
      'soilType': 'Well-drained loamy to sandy loam soils with pH 6.5-7.5. Deep fertile soils preferred.',
      'varieties': 'CO-0238, CO-05011, CO-86032, CO-94012',
      'marketPrice': 'Rs. 3,100-3,500 per quintal (varies by region)',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Cotton',
      'imageUrl': 'https://images.unsplash.com/photo-1595408076683-5d0c523c0386?w=800',
      'sowingTime': '• North India: April-May (after last frost)\n• Central India: May-June (with monsoon)\n• South India: June-July\n• Soil temperature should be >20°C',
      'irrigation': '• Total water: 600-1200 mm depending on variety\n• Critical stages: Flowering and boll formation\n• Method: Drip irrigation saves 40% water\n• Frequency: Weekly in summer\n• Avoid excess water during boll opening',
      'fertilizer': '• Nitrogen: 120-150 kg/ha (split application)\n• Phosphorus: 60-80 kg P2O5/ha\n• Potassium: 60-80 kg K2O/ha\n• Apply FYM: 10-15 tonnes/ha\n• Boron and Zinc as micronutrients',
      'pestControl': '• Bollworm: Use Bt cotton varieties, pheromone traps\n• Whitefly: Yellow sticky traps, neem spray\n• Aphids: Ladybird beetles, neem oil\n• Jassids: Resistant varieties, spray neem\n• Follow IPM practices for sustainable control',
      'harvestTime': '• Picking starts 150-180 days after sowing\n• Harvest when bolls fully open\n• Pick in dry weather only\n• Multiple pickings: 4-6 times\n• Store in clean, dry place',
      'climate': 'Warm climate with temperature 21-30°C. Requires 150-200 frost-free days. Moderate rainfall.',
      'soilType': 'Black cotton soils (vertisols), alluvial soils, loamy soils with good drainage. pH 6.5-8.0.',
      'varieties': 'RCH-659, Ankur-651, Bunny, Shiva',
      'marketPrice': 'Rs. 6,000-7,500 per quintal (varies by quality)',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Wheat',
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800',
      'sowingTime': '• Timely sown: November 1-15\n• Late sown: November 25 - December 10\n• Optimum time: First fortnight of November\n• Temperature: 20-25°C at sowing',
      'irrigation': '• Total water: 400-450 mm (4-5 irrigations)\n• Critical stages: Crown root, flowering, grain filling\n• First irrigation: 20-25 days after sowing\n• Last irrigation: 15 days before harvest\n• Avoid water stress during grain filling',
      'fertilizer': '• Nitrogen: 120-150 kg/ha (2-3 splits)\n• Phosphorus: 60 kg P2O5/ha\n• Potassium: 40 kg K2O/ha\n• Apply FYM: 10 tonnes/ha\n• Zinc sulfate: 25 kg/ha in deficient soils',
      'pestControl': '• Termites: Treat seeds with chlorpyrifos\n• Aphids: Spray dimethoate or neem oil\n• Rust diseases: Use resistant varieties\n• Karnal bunt: Treat seeds with fungicide\n• Weed control: One hand weeding or herbicide',
      'harvestTime': '• Harvest when grains hard and golden\n• Moisture content: 12-14%\n• Signs: Leaves turn yellow, stems dry\n• Use combine harvester for large areas\n• Thresh and dry before storage',
      'climate': 'Cool winter climate with temperature 10-25°C. Requires moderate rainfall during growing season.',
      'soilType': 'Well-drained loamy soils, clay loams. pH 6.0-7.5. Avoid waterlogged and saline soils.',
      'varieties': 'HD-2967, HD-3086, PBW-343, DBW-17',
      'marketPrice': 'Rs. 2,125 per quintal (MSP)',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Soybean',
      'imageUrl': 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=800',
      'sowingTime': '• Kharif season: June-July with monsoon\n• Best time: Within first week of June\n• Soil temperature: >18°C\n• Avoid late sowing after July 15',
      'irrigation': '• Generally rainfed crop\n• Critical stages: Flowering and pod filling\n• If irrigated: 2-3 irrigations maximum\n• First irrigation: At flowering\n• Second irrigation: Pod filling stage',
      'fertilizer': '• Nitrogen: 20-30 kg/ha (starter dose)\n• Phosphorus: 60-80 kg P2O5/ha\n• Potassium: 40-60 kg K2O/ha\n• Rhizobium culture: 600 g/ha seed treatment\n• Sulfur: 20 kg/ha as gypsum',
      'pestControl': '• Stem fly: Seed treatment with thiamethoxam\n• Whitefly: Yellow sticky traps, neem spray\n• Tobacco caterpillar: Hand picking, neem oil\n• Yellow mosaic virus: Use resistant varieties\n• Pod borer: Spray NSKE or quinalphos',
      'harvestTime': '• Harvest when 95% pods turn brown\n• Leaves shed, stems dry\n• Moisture content: 12-13%\n• Avoid over-ripening to prevent shattering\n• Harvest during dry weather',
      'climate': 'Warm climate with temperature 20-30°C. Moderate rainfall 600-800 mm. Well-distributed rains needed.',
      'soilType': 'Well-drained loamy soils, sandy loams. pH 6.0-7.5. Avoid saline and waterlogged soils.',
      'varieties': 'JS-335, JS-9560, NRC-37, MACS-1407',
      'marketPrice': 'Rs. 4,392 per quintal (MSP)',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Paddy (Rice)',
      'imageUrl': 'https://images.unsplash.com/photo-1536617621572-1d5f1e6269a0?w=800',
      'sowingTime': '• Kharif: May-June (transplanting June-July)\n• Rabi: November-December\n• Summer: January-February (limited areas)\n• Nursery: 4-5 weeks before transplanting',
      'irrigation': '• Total water: 1200-1500 mm\n• Critical stages: Tillering, flowering\n• Maintain 2-5 cm water during vegetative\n• Drain before harvest\n• Drought at flowering causes high yield loss',
      'fertilizer': '• Nitrogen: 100-150 kg/ha (3 splits)\n• Phosphorus: 60 kg P2O5/ha\n• Potassium: 60 kg K2O/ha\n• Apply FYM: 10 tonnes/ha\n• Zinc: 25 kg zinc sulfate/ha in deficient soils',
      'pestControl': '• Stem borer: Egg parasitoids, resistant varieties\n• Brown plant hopper: Avoid excess nitrogen\n• Blast disease: Use resistant varieties\n• Bacterial leaf blight: Use certified seeds\n• Weed management: Hand weeding at 20 and 40 days',
      'harvestTime': '• Harvest when 80-85% grains mature\n• Straw turns golden yellow\n• Moisture content: 20-22%\n• Dry to 12-14% for storage\n• Avoid field stacking to prevent quality loss',
      'climate': 'Warm humid climate with temperature 20-35°C. High rainfall 1250-2000 mm or assured irrigation.',
      'soilType': 'Clay loam, silty loam soils with good water holding. pH 5.5-6.5. Can grow in wide range of soils.',
      'varieties': 'IR-64, MTU-1010, Pusa Basmati, Swarna',
      'marketPrice': 'Rs. 2,183 per quintal (Common), Rs. 5,883 (Basmati)',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    },
  ];
}
