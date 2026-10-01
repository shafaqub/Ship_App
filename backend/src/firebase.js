const path = require('path');

const {
  initializeApp,
  getApps,
  cert,
} = require('firebase-admin/app');

const {
  getFirestore,
} = require('firebase-admin/firestore');

const serviceAccountPath = path.join(
  __dirname,
  '..',
  'firebase-service-account.json'
);

const app = getApps().length
  ? getApps()[0]
  : initializeApp({
      credential: cert(require(serviceAccountPath)),
    });

const db = getFirestore(app);

module.exports = {
  db,
};