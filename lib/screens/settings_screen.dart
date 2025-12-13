import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notification_provider.dart';
import '../services/push_notification_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/about_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text('Enable Notifications', style: GoogleFonts.poppins(color: Colors.white)),
                              value: provider.enabled,
                              activeColor: Colors.cyanAccent,
                              onChanged: (val) {
                                provider.saveSettings(
                                  enabled: val,
                                  aqiEnabled: provider.aqiEnabled,
                                  weatherEnabled: provider.weatherEnabled,
                                  frequencyMinutes: provider.frequencyMinutes,
                                );
                              },
                            ),
                            if (provider.enabled) ...[
                               const Divider(color: Colors.white24),
                               SwitchListTile(
                                title: Text('AQI Alerts', style: GoogleFonts.poppins(color: Colors.white70)),
                                value: provider.aqiEnabled,
                                activeColor: Colors.cyanAccent,
                                onChanged: (val) {
                                  provider.saveSettings(
                                    enabled: provider.enabled,
                                    aqiEnabled: val,
                                    weatherEnabled: provider.weatherEnabled,
                                    frequencyMinutes: provider.frequencyMinutes,
                                  );
                                },
                              ),
                              SwitchListTile(
                                title: Text('Weather Updates', style: GoogleFonts.poppins(color: Colors.white70)),
                                value: provider.weatherEnabled,
                                activeColor: Colors.cyanAccent,
                                onChanged: (val) {
                                  provider.saveSettings(
                                    enabled: provider.enabled,
                                    aqiEnabled: provider.aqiEnabled,
                                    weatherEnabled: val,
                                    frequencyMinutes: provider.frequencyMinutes,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Update Frequency', style: GoogleFonts.poppins(color: Colors.white70)),
                                    DropdownButton<int>(
                                      value: provider.frequencyMinutes,
                                      dropdownColor: const Color(0xFF2E335A),
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      items: const [
                                        DropdownMenuItem(value: 15, child: Text('15 min')),
                                        DropdownMenuItem(value: 30, child: Text('30 min')),
                                        DropdownMenuItem(value: 60, child: Text('60 min')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          provider.saveSettings(
                                            enabled: provider.enabled,
                                            aqiEnabled: provider.aqiEnabled,
                                            weatherEnabled: provider.weatherEnabled,
                                            frequencyMinutes: val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                             PushNotificationService().showLocalNotification(
                               id: 999,
                               title: 'Test Notification',
                               body: 'This is how cloud updates will appear.',
                             );
                          },
                          child: Text(
                            'Trigger Test Notification', 
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const AboutSection(),
                      const SizedBox(height: 32),
                      Text(
                        'Background updates may use data and battery.',
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
