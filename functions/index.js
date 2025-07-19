const { setGlobalOptions } = require("firebase-functions");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentDeleted, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { getMessaging } = require("firebase-admin/messaging");

setGlobalOptions({ maxInstances: 10 });
initializeApp();

const db = getFirestore();
const auth = getAuth();
const messaging = getMessaging();

// Helper function to get admin FCM tokens with validation
async function getAdminTokens() {
  try {
    const adminsSnapshot = await db.collection("users")
      .where("userType", "==", "admin")
      .get();
    
    const tokens = [];
    const invalidTokens = [];
    
    for (const doc of adminsSnapshot.docs) {
      const userData = doc.data();
      const userId = doc.id;
      
      if (userData.fcmToken) {
        // Basic token validation (FCM tokens are typically 152+ characters)
        if (userData.fcmToken.length > 100) {
          tokens.push(userData.fcmToken);
        } else {
          invalidTokens.push({ userId, token: userData.fcmToken });
          console.warn(`Invalid FCM token length for admin ${userId}`);
        }
      }
    }
    
    // Log if we found invalid tokens
    if (invalidTokens.length > 0) {
      console.warn(`Found ${invalidTokens.length} invalid admin FCM tokens`);
    }
    
    console.log(`Retrieved ${tokens.length} valid admin FCM tokens`);
    return tokens;
    
  } catch (error) {
    console.error("Error getting admin tokens:", error);
    return [];
  }
}

// Helper function to detect field changes
function detectChanges(before, after, watchedFields) {
  const changes = {};
  
  watchedFields.forEach(field => {
    const beforeValue = getNestedValue(before, field);
    const afterValue = getNestedValue(after, field);
    
    if (JSON.stringify(beforeValue) !== JSON.stringify(afterValue)) {
      changes[field] = {
        before: beforeValue,
        after: afterValue
      };
    }
  });
  
  return changes;
}

// Helper function to get nested object values
function getNestedValue(obj, path) {
  return path.split('.').reduce((current, key) => current?.[key], obj);
}

// Helper function to send FCM notification
async function sendNotificationToAdmins(title, body, data = {}) {
  try {
    const adminTokens = await getAdminTokens();
    
    if (adminTokens.length === 0) {
      console.log("No admin tokens found for notification");
      return;
    }

    const message = {
      notification: {
        title,
        body
      },
      data: {
        ...data,
        timestamp: new Date().toISOString()
      },
      tokens: adminTokens
    };

    const response = await messaging.sendEachForMulticast(message);
    console.log(`Notification sent to ${response.successCount} admins`);
    
    if (response.failureCount > 0) {
      console.error(`Failed to send to ${response.failureCount} tokens`);
    }
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

exports.onUserCreate = onDocumentCreated("users/{userId}", async (event) => {
  const userData = event.data?.data();
  const userId = event.params.userId;

  try {
    console.log(`Creating user profile for ${userId}`);
    
    const authUser = await auth.getUser(userId);
    const isAnonymous = authUser.providerData.length === 0;

    if (isAnonymous) {
      await db.collection("guestProfiles").doc(userId).set({
        isGuest: true,
        createdAt: FieldValue.serverTimestamp(),
        lastSeen: FieldValue.serverTimestamp()
      });

      await db.collection("guestActivities").add({
        guestId: userId,
        action: "guest_created",
        timestamp: FieldValue.serverTimestamp()
      });

      console.log(`Guest profile created for ${userId}`);
    } else {
      const userDoc = {
        uid: userId,
        email: authUser.email || "",
        phoneNumber: authUser.phoneNumber || "",
        fullName: authUser.displayName || "",
        userType: "customer",
        isVerified: false,
        profileImage: authUser.photoURL || "",
        nationalId: "",
        creditLimit: 0,
        availableCredit: 0,
        totalDebt: 0,
        rating: 0,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        employment: {
          isEmployed: true,
          employerName: "",
          jobTitle: "",
          sector: "public"
        },
        address: {
          street: "",
          city: "",
          governorate: ""
        }
      };

      await db.collection("users").doc(userId).set(userDoc);
      console.log(`Registered user profile created for ${userId}`);

      // 🔔 Notify admins about new user registration
      await notifyNewUser(userDoc);
    }
  } catch (error) {
    console.error(`Error creating user profile for ${userId}:`, error);
  }
});

// 🔔 Function to notify admins about new user
async function notifyNewUser(userData) {
  try {
    const title = "🆕 New User Registration";
    const body = `${userData.fullName || 'New User'} just registered`;
    const data = {
      type: "new_user",
      userId: userData.uid,
      email: userData.email,
      phoneNumber: userData.phoneNumber,
      fullName: userData.fullName
    };

    await sendNotificationToAdmins(title, body, data);
    console.log(`Admin notification sent for new user: ${userData.uid}`);
  } catch (error) {
    console.error("Error sending new user notification:", error);
  }
}

exports.onUserVerified = onCall(async (request) => {
  const { userId } = request.data;
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  if (authContext.uid !== userId) {
    throw new Error("Unauthorized: Can only verify own account");
  }

  try {
    const authUser = await auth.getUser(userId);
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    
    if (authUser.emailVerified || authUser.phoneNumber) {
      await db.collection("users").doc(userId).update({
        isVerified: true,
        verifiedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp()
      });

      // 📊 Track verification event
      await trackVerificationEvent(userId, authUser, userData);

      console.log(`User ${userId} verified successfully`);
      return { success: true, message: "User verified successfully" };
    } else {
      throw new Error("Email or phone number not verified");
    }
  } catch (error) {
    console.error(`Error verifying user ${userId}:`, error);
    throw new Error("Failed to verify user");
  }
});

// 📊 Function to track verification events
async function trackVerificationEvent(uid, authUser, userData) {
  try {
    const verificationMethod = authUser.emailVerified ? "email" : "phone";
    const isGuest = authUser.providerData.length === 0;
    const userType = isGuest ? "guest" : (userData?.userType || "registered");

    const verificationEvent = {
      uid,
      verifiedAt: FieldValue.serverTimestamp(),
      method: verificationMethod,
      byUserType: userType,
      email: authUser.email || "",
      phoneNumber: authUser.phoneNumber || ""
    };

    await db.collection("verificationEvents").doc(uid).set(verificationEvent);
    console.log(`Verification event tracked for ${uid} via ${verificationMethod}`);
  } catch (error) {
    console.error("Error tracking verification event:", error);
  }
}

exports.logLogin = onCall(async (request) => {
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  const userId = authContext.uid;
  const isAnonymous = authContext.token.firebase.sign_in_provider === "anonymous";

  try {
    if (isAnonymous) {
      await db.collection("guestProfiles").doc(userId).update({
        lastSeen: FieldValue.serverTimestamp()
      });
      
      await db.collection("guestActivities").add({
        guestId: userId,
        action: "guest_login",
        timestamp: FieldValue.serverTimestamp()
      });
    } else {
      await db.collection("users").doc(userId).update({
        lastLoginAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp()
      });
    }

    console.log(`Login logged for user ${userId}`);
    return { success: true, message: "Login logged successfully" };
  } catch (error) {
    console.error(`Error logging login for user ${userId}:`, error);
    throw new Error("Failed to log login");
  }
});

exports.logLogout = onCall(async (request) => {
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  const userId = authContext.uid;
  const isAnonymous = authContext.token.firebase.sign_in_provider === "anonymous";

  try {
    if (isAnonymous) {
      await db.collection("guestProfiles").doc(userId).update({
        lastSeen: FieldValue.serverTimestamp()
      });

      await db.collection("guestActivities").add({
        guestId: userId,
        action: "guest_logout",
        timestamp: FieldValue.serverTimestamp()
      });
    } else {
      await db.collection("users").doc(userId).update({
        lastLogoutAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp()
      });
    }

    console.log(`Logout logged for user ${userId}`);
    return { success: true, message: "Logout logged successfully" };
  } catch (error) {
    console.error(`Error logging logout for user ${userId}:`, error);
    throw new Error("Failed to log logout");
  }
});

exports.onUserDelete = onDocumentDeleted("users/{userId}", async (event) => {
  const userId = event.params.userId;
  const deletedUserData = event.data?.data();

  try {
    console.log(`Starting user deletion cleanup for ${userId}`);

    // Clean up guest profile if exists
    const guestDoc = await db.collection("guestProfiles").doc(userId).get();
    if (guestDoc.exists) {
      await db.collection("guestProfiles").doc(userId).delete();
      console.log(`Guest profile deleted for ${userId}`);
    }

    // Log FCM token cleanup if user had one
    if (deletedUserData?.fcmToken) {
      await db.collection("userLogs").add({
        userId,
        action: "fcm_token_cleanup_on_deletion",
        tokenData: {
          hadToken: true,
          tokenPrefix: deletedUserData.fcmToken.substring(0, 10) + "...",
          userType: deletedUserData.userType || "unknown"
        },
        timestamp: FieldValue.serverTimestamp()
      });
      console.log(`FCM token cleanup logged for deleted user ${userId}`);
    }

    // Clean up user logs older than 90 days for this user
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
    
    const oldLogsSnapshot = await db.collection("userLogs")
      .where("userId", "==", userId)
      .where("timestamp", "<", ninetyDaysAgo)
      .get();

    if (!oldLogsSnapshot.empty) {
      const batch = db.batch();
      oldLogsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`Cleaned up ${oldLogsSnapshot.size} old logs for user ${userId}`);
    }

    console.log(`User deletion cleanup completed for ${userId}`);
  } catch (error) {
    console.error(`Error during user deletion cleanup for ${userId}:`, error);
  }
});

exports.onGuestDelete = onDocumentDeleted("guestProfiles/{guestId}", async (event) => {
  const guestId = event.params.guestId;

  try {
    const userDoc = await db.collection("users").doc(guestId).get();
    if (userDoc.exists) {
      await db.collection("users").doc(guestId).delete();
      console.log(`User profile deleted for converted guest ${guestId}`);
    }

    console.log(`Guest deletion cleanup completed for ${guestId}`);
  } catch (error) {
    console.error(`Error during guest deletion cleanup for ${guestId}:`, error);
  }
});

// ✅ User Update Tracking with Change Detection
exports.onUserUpdate = onDocumentUpdated("users/{userId}", async (event) => {
  const beforeData = event.data?.before?.data();
  const afterData = event.data?.after?.data();
  const userId = event.params.userId;

  if (!beforeData || !afterData) {
    console.log(`Skipping update processing for ${userId} - missing data`);
    return;
  }

  try {
    console.log(`Processing user update for ${userId}`);

    // Define fields to watch for changes
    const watchedFields = [
      "phoneNumber",
      "fullName", 
      "address.street",
      "address.city",
      "address.governorate",
      "employment.isEmployed",
      "employment.employerName",
      "employment.jobTitle",
      "employment.sector"
    ];

    // Detect changes in watched fields
    const changes = detectChanges(beforeData, afterData, watchedFields);

    if (Object.keys(changes).length > 0) {
      console.log(`Detected changes in user ${userId}:`, changes);

      // Update the updatedAt timestamp
      await db.collection("users").doc(userId).update({
        updatedAt: FieldValue.serverTimestamp()
      });

      // Log changes to userLogs collection
      await db.collection("userLogs").add({
        userId,
        action: "profile_update",
        changes,
        timestamp: FieldValue.serverTimestamp(),
        userType: afterData.userType || "customer"
      });

      console.log(`User update logged for ${userId}`);
    }

    // 🛡️ Check for dangerous field change attempts
    await checkDangerousChanges(beforeData, afterData, userId);

  } catch (error) {
    console.error(`Error processing user update for ${userId}:`, error);
  }
});

// 🛡️ Security Audit for Dangerous Change Attempts
async function checkDangerousChanges(beforeData, afterData, userId) {
  try {
    const restrictedFields = ["creditLimit", "totalDebt", "rating", "availableCredit"];
    const dangerousAttempts = {};

    restrictedFields.forEach(field => {
      const beforeValue = beforeData[field];
      const afterValue = afterData[field];
      
      if (beforeValue !== afterValue) {
        dangerousAttempts[field] = {
          before: beforeValue,
          after: afterValue
        };
      }
    });

    if (Object.keys(dangerousAttempts).length > 0) {
      console.warn(`🚨 Dangerous change attempt detected for user ${userId}:`, dangerousAttempts);

      // Log security event
      await db.collection("securityEvents").add({
        userId,
        eventType: "restricted_field_modification_attempt",
        attemptedChanges: dangerousAttempts,
        timestamp: FieldValue.serverTimestamp(),
        severity: "high",
        userType: afterData.userType || "customer"
      });

      // Notify admins
      await sendNotificationToAdmins(
        "🚨 Security Alert",
        `User ${afterData.fullName || userId} attempted to modify restricted fields`,
        {
          type: "security_alert",
          userId,
          eventType: "restricted_modification"
        }
      );

      console.log(`Security event logged for dangerous change attempt by ${userId}`);
    }
  } catch (error) {
    console.error("Error checking dangerous changes:", error);
  }
}

// 📊 Daily Guest Analytics - Runs at midnight daily
exports.auditGuestActivity = onSchedule("0 0 * * *", async (event) => {
  try {
    console.log("Starting daily guest activity audit");

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    yesterday.setHours(0, 0, 0, 0);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get all guest profiles
    const guestSnapshot = await db.collection("guestProfiles").get();
    
    let totalGuests = 0;
    let activeGuests = 0;
    let newGuests = 0;

    guestSnapshot.forEach(doc => {
      const guestData = doc.data();
      totalGuests++;

      // Check if guest was active yesterday
      if (guestData.lastSeen && guestData.lastSeen.toDate() >= yesterday) {
        activeGuests++;
      }

      // Check if guest was created yesterday
      if (guestData.createdAt && guestData.createdAt.toDate() >= yesterday && guestData.createdAt.toDate() < today) {
        newGuests++;
      }
    });

    // Get guest activities for yesterday
    const activitiesSnapshot = await db.collection("guestActivities")
      .where("timestamp", ">=", yesterday)
      .where("timestamp", "<", today)
      .get();

    const activityCounts = {};
    activitiesSnapshot.forEach(doc => {
      const activity = doc.data();
      activityCounts[activity.action] = (activityCounts[activity.action] || 0) + 1;
    });

    // Store daily summary
    const dailySummary = {
      date: yesterday,
      totalGuests,
      activeGuests,
      newGuests,
      activityCounts,
      generatedAt: FieldValue.serverTimestamp()
    };

    const dateStr = yesterday.toISOString().split('T')[0];
    await db.collection("guestAnalytics").doc(dateStr).set(dailySummary);

    console.log(`Daily guest analytics completed:`, dailySummary);

    // Notify admins with summary
    if (activeGuests > 0 || newGuests > 0) {
      await sendNotificationToAdmins(
        "📊 Daily Guest Report",
        `${activeGuests} active guests, ${newGuests} new guests yesterday`,
        {
          type: "daily_report",
          activeGuests: activeGuests.toString(),
          newGuests: newGuests.toString()
        }
      );
    }

  } catch (error) {
    console.error("Error in daily guest activity audit:", error);
  }
});

// 🔔 FCM Token Registration - Callable Function
exports.registerFCMToken = onCall(async (request) => {
  const { fcmToken, deviceInfo } = request.data;
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  if (!fcmToken) {
    throw new Error("FCM token is required");
  }

  const userId = authContext.uid;

  try {
    console.log(`Registering FCM token for user ${userId}`);

    // Update user document with FCM token
    const updateData = {
      fcmToken,
      fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp()
    };

    // Add device info if provided
    if (deviceInfo) {
      updateData.deviceInfo = {
        platform: deviceInfo.platform || "",
        model: deviceInfo.model || "",
        version: deviceInfo.version || "",
        lastUpdated: FieldValue.serverTimestamp()
      };
    }

    await db.collection("users").doc(userId).update(updateData);

    // Log FCM token registration event
    await db.collection("userLogs").add({
      userId,
      action: "fcm_token_registered", 
      tokenData: {
        hasToken: true,
        deviceInfo: deviceInfo || null
      },
      timestamp: FieldValue.serverTimestamp()
    });

    console.log(`FCM token registered successfully for user ${userId}`);
    return { 
      success: true, 
      message: "FCM token registered successfully",
      tokenId: fcmToken.substring(0, 10) + "..." // Return partial token for confirmation
    };

  } catch (error) {
    console.error(`Error registering FCM token for user ${userId}:`, error);
    throw new Error("Failed to register FCM token");
  }
});

// 🔔 FCM Token Refresh - Callable Function
exports.refreshFCMToken = onCall(async (request) => {
  const { oldToken, newToken } = request.data;
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  if (!newToken) {
    throw new Error("New FCM token is required");
  }

  const userId = authContext.uid;

  try {
    console.log(`Refreshing FCM token for user ${userId}`);

    // Update user document with new FCM token
    await db.collection("users").doc(userId).update({
      fcmToken: newToken,
      fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp()
    });

    // Log token refresh event
    await db.collection("userLogs").add({
      userId,
      action: "fcm_token_refreshed",
      tokenData: {
        oldTokenPrefix: oldToken ? oldToken.substring(0, 10) + "..." : "none",
        newTokenPrefix: newToken.substring(0, 10) + "..."
      },
      timestamp: FieldValue.serverTimestamp()
    });

    console.log(`FCM token refreshed successfully for user ${userId}`);
    return { 
      success: true, 
      message: "FCM token refreshed successfully"
    };

  } catch (error) {
    console.error(`Error refreshing FCM token for user ${userId}:`, error);
    throw new Error("Failed to refresh FCM token");
  }
});

// 🔔 FCM Token Removal - Callable Function  
exports.removeFCMToken = onCall(async (request) => {
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  const userId = authContext.uid;

  try {
    console.log(`Removing FCM token for user ${userId}`);

    // Remove FCM token from user document
    await db.collection("users").doc(userId).update({
      fcmToken: FieldValue.delete(),
      fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp()
    });

    // Log token removal event
    await db.collection("userLogs").add({
      userId,
      action: "fcm_token_removed",
      tokenData: {
        hasToken: false,
        reason: "user_logout_or_uninstall"
      },
      timestamp: FieldValue.serverTimestamp()
    });

    console.log(`FCM token removed successfully for user ${userId}`);
    return { 
      success: true, 
      message: "FCM token removed successfully"
    };

  } catch (error) {
    console.error(`Error removing FCM token for user ${userId}:`, error);
    throw new Error("Failed to remove FCM token");
  }
});

// 🔔 Test FCM Notification - Callable Function (Admin Only)
exports.testFCMNotification = onCall(async (request) => {
  const { title, body, targetUserId } = request.data;
  const authContext = request.auth;

  if (!authContext) {
    throw new Error("Authentication required");
  }

  try {
    // Check if caller is admin
    const callerDoc = await db.collection("users").doc(authContext.uid).get();
    const callerData = callerDoc.data();
    
    if (!callerData || callerData.userType !== "admin") {
      throw new Error("Admin access required");
    }

    let targetTokens = [];

    if (targetUserId) {
      // Send to specific user
      const targetDoc = await db.collection("users").doc(targetUserId).get();
      const targetData = targetDoc.data();
      if (targetData?.fcmToken) {
        targetTokens.push(targetData.fcmToken);
      }
    } else {
      // Send to all admins
      targetTokens = await getAdminTokens();
    }

    if (targetTokens.length === 0) {
      throw new Error("No FCM tokens found for target recipients");
    }

    const message = {
      notification: {
        title: title || "🧪 Test Notification",
        body: body || "This is a test notification from Qasetha Admin"
      },
      data: {
        type: "test_notification",
        sentBy: authContext.uid,
        timestamp: new Date().toISOString()
      },
      tokens: targetTokens
    };

    const response = await messaging.sendEachForMulticast(message);
    
    console.log(`Test notification sent to ${response.successCount} devices`);
    
    return {
      success: true,
      message: `Notification sent to ${response.successCount} devices`,
      successCount: response.successCount,
      failureCount: response.failureCount
    };

  } catch (error) {
    console.error("Error sending test notification:", error);
    throw new Error(`Failed to send test notification: ${error.message}`);
  }
});
