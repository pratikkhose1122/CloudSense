import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudsense/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    // Load test environment variables
    dotenv.testLoad(mergeWith: {'OPENWEATHER_API_KEY': 'test_key'});
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Allow microtasks to run (fetching data)
    await tester.pump(); 
    // Wait a bit for any immediate async logic (but don't wait for periodic timers)
    await tester.pump(const Duration(seconds: 1));

    // Verify that our title text is present
    expect(find.text('CloudSense'), findsOneWidget);
  });
}
