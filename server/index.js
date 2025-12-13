import admin from "firebase-admin";
import { createRequire } from "module";
const require = createRequire(import.meta.url);

// Check if key exists
try {
    const serviceAccount = require('./service-account.json');
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
} catch (e) {
    console.error("Error: 'service-account.json' not found. Please download it from Firebase Console.");
    process.exit(1);
}

// SEND AQI ALERT
export async function sendAqiAlert(city, aqi, category) {
    const message = {
        topic: "aqi_alerts",
        notification: {
            title: `AQI Alert — ${city}`,
            body: `AQI ${aqi} — ${category}. Tap to view details.`,
        },
        data: {
            type: "aqi",
            aqi: String(aqi),
            city: city,
            category: category,
        }
    };
    await admin.messaging().send(message);
    console.log("AQI alert sent!");
}

// SEND WEATHER ALERT
export async function sendWeatherAlert(city, temp, condition) {
    const message = {
        topic: "weather_updates",
        notification: {
            title: `Weather Update — ${city}`,
            body: `${temp}°C — ${condition}`,
        },
        data: {
            type: "weather",
            city: city,
            temp: String(temp),
            condition: condition,
        }
    };
    await admin.messaging().send(message);
    console.log("Weather alert sent!");
}

// Quick Test Execution if run directly
// node index.js
if (import.meta.url === `file://${process.argv[1]}`) {
    console.log("Running test alerts...");
    // setTimeout to allow async init if needed, though here it's sync
    setTimeout(async () => {
        try {
            await sendAqiAlert("Pune", 155, "Unhealthy");
            // await sendWeatherAlert("London", 12, "Rainy"); // Optional test
        } catch (e) {
            console.error("Failed to send alert:", e);
        }
    }, 1000);
}
