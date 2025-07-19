import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Cloud Function triggered when a new user is created
export const createUserDocument = functions.auth.user().onCreate(async (user) => {
  console.log('🚀 New user created:', user.uid);
  
  try {
    // Extract user data
    const userData = {
      fullName: "",
      email: user.email || "",
      phoneNumber: user.phoneNumber || "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      userType: "customer",
      isVerified: false,
      uid: user.uid
    };

    console.log('📝 Creating user document with data:', userData);

    // Create user document in Firestore
    await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .set(userData);

    console.log('✅ User document created successfully for:', user.uid);
    
  } catch (error) {
    console.error('❌ Error creating user document:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create user document');
  }
});

// Optional: Cloud Function to handle user deletion
export const deleteUserDocument = functions.auth.user().onDelete(async (user) => {
  console.log('🗑️ User deleted:', user.uid);
  
  try {
    await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .delete();
      
    console.log('✅ User document deleted successfully for:', user.uid);
    
  } catch (error) {
    console.error('❌ Error deleting user document:', error);
  }
});