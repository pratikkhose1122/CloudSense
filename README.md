# WeatherWise

A premium, modern Flutter weather application featuring a "Liquid Glass" frosted UI, live updates, and location integration.

## Features
- **Modern UI**: Frosted glassmorphism design with liquid backgrounds and smooth animations.
- **Glass Container**: Custom reusable widget for blur effects.
- **City Search**: Search for weather in any city globally.
- **Live Updates**: Real-time temperature, humidity, wind, and conditions using OpenWeatherMap.
- **Auto-Refresh**: Data refreshes automatically every 10 minutes.
- **Location Support**: Get weather for your current GPS location.
- **Pull-to-Refresh**: Manually refresh data with a swipe.

## Screenshots
| Home Glass | Weather Card | Location |
|:---:|:---:|:---:|
| ![Home](assets/screenshots/home_glass.png) | ![Card](assets/screenshots/weather_card_glass.png) | ![Location](assets/screenshots/location_glass.png) |

## Setup
1. Clone repo.
2. Create `.env` file with `OPENWEATHER_API_KEY=your_key`.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Tech Stack
- Flutter (Dart)
- Provider (State Management)
- HTTP (API)
- Geolocator (GPS)
- Google Fonts (Typography)
- Dart UI (BackdropFilter/Blur)
