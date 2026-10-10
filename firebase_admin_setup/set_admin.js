
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

async function setAdminRole() {
  try {
    const email = 'admin@carecircle.com';

    const user = await getAuth().getUserByEmail(email);

    await getAuth().setCustomUserClaims(user.uid, {
      ...(user.customClaims || {}),
      admin: true,
    });

    console.log('Admin role assigned successfully!');
    console.log('Admin email:', email);
  } catch (error) {
    console.error('Error:', error.message);
    process.exitCode = 1;
  }
}

setAdminRole();
