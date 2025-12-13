import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/glass_container.dart';
import '../widgets/forecast_section.dart';
import '../widgets/animated_weather_background.dart';
import '../providers/air_quality_provider.dart';
import '../widgets/aqi_card.dart';
import '../widgets/aqi_badge.dart';
import '../services/push_notification_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aqiKey = GlobalKey();
  
  Timer? _timer;
  String _currentCity = 'Pune';

  StreamSubscription? _notifSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _search(_currentCity));

    _timer = Timer.periodic(const Duration(minutes: 10), (_) {
      _search(_currentCity);
    });

    // Deep Linking Listener
    _notifSubscription = PushNotificationService().actionStream.listen((action) {
      if (action == 'aqi') {
        // Delay slightly to ensure UI is ready or frame is rendered
        Future.delayed(const Duration(milliseconds: 500), _scrollToAqi);
      } else if (action == 'weather') {
        _scrollController.animateTo(
          0, 
          duration: const Duration(milliseconds: 600), 
          curve: Curves.easeInOut
        );
      }
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    _timer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _search(String city) async {
    _currentCity = city;
    await Provider.of<WeatherProvider>(context, listen: false).search(city);
    if (mounted) {
      final weather = Provider.of<WeatherProvider>(context, listen: false).weather;
      if (weather != null) {
        await Provider.of<AirQualityProvider>(context, listen: false)
            .fetchByCoords(weather.lat, weather.lon);
      }
    }
  }

  Future<void> _refresh() async {
    await _search(_currentCity);
  }

  Future<void> _useLocation() async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    await provider.searchByCoords(position.latitude, position.longitude);
    if (mounted) {
       await Provider.of<AirQualityProvider>(context, listen: false)
          .fetchByCoords(position.latitude, position.longitude);
    }
  }

  String _mapToCondition(String? iconCode) {
    if (iconCode == null) return 'clear';
    if (iconCode.startsWith('01')) return 'clear';
    if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) return 'clouds';
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return 'rain';
    if (iconCode.startsWith('13')) return 'snow';
    if (iconCode.endsWith('n')) return 'night';
    return 'clouds';
  }

  void _scrollToAqi() {
    final context = _aqiKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context, 
        duration: const Duration(milliseconds: 600), 
        curve: Curves.easeInOut
      );
    } else {
      // Fallback if not yet visible (scroll to bottom)
      _scrollController.animateTo(
         _scrollController.position.maxScrollExtent, 
         duration: const Duration(milliseconds: 600), 
         curve: Curves.easeInOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final condition = _mapToCondition(weatherProvider.weather?.icon);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CloudSense',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // AQI Badge
          Consumer<AirQualityProvider>(
            builder: (context, aqiProvider, _) {
              if (aqiProvider.current == null) return const SizedBox();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AqiBadge(
                    airQuality: aqiProvider.current!,
                    onTap: _scrollToAqi,
                  ),
                ),
              );
            },
          ),
          Container(
             margin: const EdgeInsets.only(right: 8),
             child: GlassContainer(
               width: 40, 
               height: 40, borderRadius: 12, padding: EdgeInsets.zero, blur: 5,
               child: IconButton(
                 icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
               ),
             ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GlassContainer(
              width: 40,
              height: 40,
              borderRadius: 12,
              padding: EdgeInsets.zero,
              blur: 5,
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
                onPressed: _useLocation,
                tooltip: 'My Location',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Animated Weather Background
          AnimatedWeatherBackground(condition: condition),
          
          // 2. Main Glass Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.cyanAccent,
              backgroundColor: const Color(0xFF2E335A),
              child: SizedBox(
                height: size.height,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Input
                          GlassContainer(
                            borderRadius: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 60,
                            blur: 20,
                            // High contrast for input area
                            gradient: LinearGradient(
                               colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                            ),
                            child: Center(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: 'Search for a city...',
                                  hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16,),
                                      onPressed: () { 
                                         if(_searchController.text.isNotEmpty) _search(_searchController.text);
                                      },
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _search(value);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Weather Status
                          Consumer<WeatherProvider>(
                            builder: (context, provider, child) {
                              if (provider.loading) {
                                return const SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
                                );
                              }
                              if (provider.error != null) {
                                return GlassContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            size: 64, color: Colors.redAccent),
                                        const SizedBox(height: 16),
                                        Text(
                                          provider.error!,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                                        ),
                                        const SizedBox(height: 20),
                                        TextButton(
                                          onPressed: () => _search(_currentCity),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.white.withOpacity(0.1),
                                          ),
                                          child: const Text('Try Again'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (provider.weather == null) {
                                return const GlassContainer(
                                  child: SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Text('Enter a city to start',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: [
                                  WeatherCard(weather: provider.weather!),
                                  const SizedBox(height: 24),
                                  const ForecastSection(),
                                  const SizedBox(height: 24),
                                  Consumer<AirQualityProvider>(
                                    builder: (context, aqiProvider, child) {
                                      if (aqiProvider.current != null) {
                                        return Container(
                                          key: _aqiKey,
                                          child: AqiCard(airQuality: aqiProvider.current!)
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Footer
                          Text(
                            "Pull down to refresh • Auto-updates every 10 min",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
