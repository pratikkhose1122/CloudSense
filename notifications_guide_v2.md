# CloudSense Push Notification Guide (Full Implementation)

## 1. Firebase Setup (Crucial)
You **MUST** perform these steps manually as they involve sensitive keys.

### Android
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Project Settings > General > Your Apps > Android.
3. Download `google-services.json`.
4. Place it in: `android/app/google-services.json`.

### Server (Sending Notifications)
1. Go to Firebase Console > Project Settings > Service accounts.
2. Click **Generate new private key**.
3. Save the file as `service-account.json` inside the `server/` folder.

## 2. Client-Side (Flutter)
- **Deep Linking**: Tapping a notification with `type: 'aqi'` automatically scrolls the Home Screen to the AQI card.
- **Subscriptions**: App automatically subscribes to `aqi_alerts` and `weather_updates` on launch (and respects Settings toggles).
- **Background Support**: Notifications work when app is closed or in background.

## 3. Server-Side (Node.js)
The server script uses ES Modules (`import`/`export`).

### Setup
```bash
cd server
npm install
```

### Sending Test Alerts
Run the script to send a sample AQI alert:
```bash
node index.js
```
Expected output:
```
Running test alerts...
AQI alert sent!
```

## 4. Deep Linking Logic
The deep linking is handled via a Stream in `push_notification_service.dart`:
```dart
// Stream action
_actionController.add(data['type']);
```
And listened to in `HomeScreen.dart` inside `initState`:
```dart
_notifSubscription = PushNotificationService().actionStream.listen((action) {
  if (action == 'aqi') _scrollToAqi();
  // ...
});
```

## 5. Troubleshooting
- **No Notification?** Check if emulator has Google Play Services.
- **Background not working?** Ensure `firebase_messaging` background handler is static/top-level (it is).
- **Permission denied?** Check AndroidManifest `POST_NOTIFICATIONS` (added).
