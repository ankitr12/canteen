/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();
sgMail.setApiKey(process.env.SENDGRID_API_KEY);


// Replace with your actual SendGrid API Key
const SENDGRID_API_KEY = "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";
sgMail.setApiKey(SENDGRID_API_KEY);

exports.sendOtp = functions.https.onCall(async (data, context) => {
  const { email } = data;
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  // Store OTP and expiration in Firestore
  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + 5);

  await admin.firestore().collection("otp_logs").doc(email).set({
    otp,
    expiresAt: expiresAt.toISOString(),
  });

  // Send the OTP email
  const msg = {
    to: email,
    from: "ankitratnani2004@gmail.com", // Replace with your verified email
    subject: "Your OTP Code",
    text: `Your OTP is ${otp}. It will expire in 5 minutes.`,
  };

  try {
    await sgMail.send(msg);
    return { success: true, message: "OTP sent successfully." };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Error sending OTP email.");
  }
});
