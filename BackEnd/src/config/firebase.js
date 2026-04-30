const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../env") });

const adminFirebase = require("firebase-admin");

const serviceAccount = require(
  path.resolve(process.cwd(), process.env.FIREBASE_KEY_PATH),
);

adminFirebase.initializeApp({
  credential: adminFirebase.credential.cert(serviceAccount),
});

module.exports = { adminFirebase };
