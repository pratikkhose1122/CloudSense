const admin = require('firebase-admin');

// INSTRUCTIONS:
// 1. Go to Firebase Console > Project Settings > Service accounts.
// 2. Generate new private key.
// 3. Save the JSON file as 'service-account.json' in this directory.
// 4. Run `npm install`
// 5. Run `node send_alert.js` to test.

// Check if key exists
try {
    const serviceAccount = require('./service-account.json');
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
} catch (e) {
    console.error("Error: 'service-account.json' not found. Please download it from Firebase Console.");
    console.error("See instructions in file header.");
    process.exit(1);
}

const topic = 'aqi_alerts';

const message = {
    notification: {
        title: 'High AQI Alert ⚠️',
        body: 'Air quality in Pune has dropped to Unhealthy (155). Wear a mask!',
    },
    data: {
        payload: 'aqi_details_screen', // Logic to navigate can be added in app
        aqi: '155',
        city: 'Pune'
    },
    topic: topic
};

console.log(`Sending message to topic: ${topic}...`);

admin.messaging().send(message)
    .then((response) => {
        console.log('Successfully sent message:', response);
    })
    .catch((error) => {
        console.log('Error sending message:', error);
    });
