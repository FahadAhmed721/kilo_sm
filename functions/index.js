/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendToTopic = functions.https.onRequest(async (req, res) => {
    const message = {
        notification: {
            title: 'New Notification',
            body: 'This is a notification to all users.'
        },
        topic: 'all'
    };

    try {
        await admin.messaging().send(message);
        res.status(200).send('Notification sent successfully.');
    } catch (error) {
        console.error('Error sending notification:', error);
        res.status(500).send('Error sending notification.');
    }
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
