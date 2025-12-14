# CloudSense – Weather & AQI App

CloudSense is a comprehensive weather and air quality monitoring application built with Flutter. It provides real-time updates, detailed insights, and notifications to help you stay informed about your environment.

## Features

- **Real-time Weather**: Current temperature, humidity, wind speed, and more.
- **Air Quality Index (AQI)**: Detailed pollutant tracking (PM2.5, PM10, CO, NO2, etc.) with health recommendations.
- **Smart Notifications**: Receive alerts for poor air quality or severe weather conditions.
- **Location-based**: Automatic location detection for hyper-local data.
- **Modern UI**: A clean, intuitive, and beautiful user interface using the latest Flutter design patterns.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend/Services**: Firebase (Cloud Messaging, Core)
- **APIs**: OpenWeatherMap (Weather & Air Pollution)
- **Charts**: fl_chart for visual data representation
- **Storage**: Shared Preferences
- **Background Tasks**: Workmanager
- **Platforms**: Android, iOS

## Screenshots

<div style="display: flex; flex-direction: row; overflow-x: auto;">
  <img src="assets/screenshots/home.png" width="200" alt="Home Screen" style="margin-right: 10px;" />
  <img src="assets/screenshots/details.png" width="200" alt="Details Screen" style="margin-right: 10px;" />
  <img src="assets/screenshots/settings.png" width="200" alt="Settings Screen" />
</div>

> **Note**: Screenshot images should be placed in `assets/screenshots/`.

## Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/pratikkhose1122/CloudSense.git
    cd CloudSense
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration:**
    Create a `.env` file in the root directory and add your API keys:
    ```env
    OPENWEATHER_API_KEY=your_api_key_here
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Firebase Configuration

This project uses Firebase for Push Notifications.

1.  Create a project in the [Firebase Console](https://console.firebase.google.com/).
2.  Add an Android app.
3.  Download `google-services.json` and place it in specific directories:
    - **Android**: `android/app/google-services.json`
4.  (Optional) For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`.

## Push Notifications

Push notifications are handled via Firebase Cloud Messaging (FCM).
- The app subscribes to topics like `aqi_alerts` and `weather_updates`.
- A backend service (Node.js or similar) is required to trigger these notifications based on weather conditions.
- This project includes local notification handling using `flutter_local_notifications`.

## Project Structure

```
lib/
├── models/         # Data models (Weather, AQI, etc.)
├── screens/        # UI Screens (Home, Details, Settings)
├── services/       # API and logic services (WeatherService, NotificationService)
├── widgets/        # Reusable UI components
├── main.dart       # App entry point
```

## Developed By

**Pratik Khose**
- GitHub: [https://github.com/pratikkhose1122](https://github.com/pratikkhose1122)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
