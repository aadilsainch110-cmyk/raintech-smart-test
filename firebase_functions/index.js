const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// Rate limiting using Firestore
const MAX_ATTEMPTS = 5;
const ATTEMPT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes

/**
 * Verify secret code and authenticate user
 * This function provides secure server-side verification of secret codes
 */
exports.verifySecretCode = functions.https.onCall(async (data, context) => {
  const { secretCode } = data;

  // Validate input
  if (!secretCode || typeof secretCode !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Secret code is required'
    );
  }

  // Validate secret code format
  if (!isValidSecretCodeFormat(secretCode)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Secret code must be exactly 6 digits'
    );
  }

  // Note: Role is now determined from the user's account, not from the code

  // Rate limiting: Check recent attempts from this IP/caller
  const callerIp = context.rawRequest.ip;
  const rateLimitRef = db.collection('rate_limits').doc(callerIp);
  const rateLimitDoc = await rateLimitRef.get();

  if (rateLimitDoc.exists) {
    const attempts = rateLimitDoc.data().attempts || [];
    const now = Date.now();
    const recentAttempts = attempts.filter(
      attempt => now - attempt.timestamp < ATTEMPT_WINDOW_MS
    );

    if (recentAttempts.length >= MAX_ATTEMPTS) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Too many attempts. Please try again later.'
      );
    }

    // Update attempts
    recentAttempts.push({ timestamp: now, code: secretCode });
    await rateLimitRef.update({ attempts: recentAttempts });
  } else {
    // First attempt
    await rateLimitRef.set({
      attempts: [{ timestamp: Date.now(), code: secretCode }]
    });
  }

  // Query for user with this secret code
  const usersSnapshot = await db
    .collection('users')
    .where('secretCode', '==', secretCode)
    .limit(1)
    .get();

  if (usersSnapshot.empty) {
    throw new functions.https.HttpsError(
      'not-found',
      'Invalid secret code'
    );
  }

  const userDoc = usersSnapshot.docs[0];
  const userData = userDoc.data();

  // Role is now determined from the user's account
  const role = userData.role;

  // Admin cannot login with secret code
  if (role === 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Admin must use email/password login'
    );
  }

  // Check if account is active
  if (userData.isActive === false) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'This account has been deactivated'
    );
  }

  // Check approval status
  if (userData.approvalStatus === 'pending') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Your account is pending approval. Admin Approved you and then enter.'
    );
  }

  if (userData.approvalStatus === 'rejected') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Your account has been rejected by Admin.'
    );
  }

  // Return user data (without sensitive information)
  return {
    userId: userDoc.id,
    name: userData.name,
    email: userData.email,
    role: userData.role,
    isActive: userData.isActive,
    approvalStatus: userData.approvalStatus,
  };
});

/**
 * Helper function to validate secret code format (exactly 6 numeric digits)
 */
function isValidSecretCodeFormat(code) {
  // Must be exactly 6 characters
  if (code.length !== 6) return false;

  // Must contain only digits
  if (!/^\d{6}$/.test(code)) return false;

  return true;
}

/**
 * Helper function to extract role from secret code
 * Note: Since we now use 6-digit codes without prefixes, role is determined
 * from the user account in Firebase, not from the code itself
 */
function getRoleFromSecretCode(code) {
  // Role is now determined from the user's account, not the code
  return null;
}

/**
 * Scheduled function to clean up old rate limit entries
 * Runs every hour
 */
exports.cleanupRateLimits = functions.pubsub
  .schedule('0 * * * *')
  .onRun(async (context) => {
    const now = Date.now();
    const cutoff = now - ATTEMPT_WINDOW_MS;

    const snapshot = await db.collection('rate_limits').get();
    const batch = db.batch();

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const recentAttempts = (data.attempts || []).filter(
        attempt => attempt.timestamp > cutoff
      );

      if (recentAttempts.length === 0) {
        // Delete if no recent attempts
        batch.delete(doc.ref);
      } else {
        // Update with only recent attempts
        batch.update(doc.ref, { attempts: recentAttempts });
      }
    });

    await batch.commit();
    console.log('Cleaned up rate limits');
  });

/**
 * Permanently delete a user account
 * This function deletes the user from Firebase Authentication and Firestore,
 * along with all related records
 */
exports.deleteUserPermanently = functions.https.onCall(async (data, context) => {
  const { userId, requesterId } = data;

  // Validate input
  if (!userId || typeof userId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'User ID is required'
    );
  }

  if (!requesterId || typeof requesterId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Requester ID is required'
    );
  }

  // Prevent self-deletion
  if (userId === requesterId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'You cannot delete your own account'
    );
  }

  try {
    // Verify requester is an admin
    const requesterDoc = await db.collection('users').doc(requesterId).get();
    if (!requesterDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Requester not found'
      );
    }

    const requesterData = requesterDoc.data();
    if (requesterData.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only admins can delete users'
      );
    }

    // Get the user to delete
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'User not found'
      );
    }

    const userData = userDoc.data();
    const userRole = userData.role;

    // Check if it's an admin account
    if (userRole === 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Cannot delete admin accounts'
      );
    }

    // For teachers, check if they own any tests
    if (userRole === 'teacher') {
      const testsSnapshot = await db.collection('tests')
        .where('teacherId', '==', userId)
        .get();

      if (!testsSnapshot.empty) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Cannot delete teacher with ${testsSnapshot.size} test(s). Please reassign or delete tests first.`
        );
      }
    }

    // Start a batch for Firestore deletions
    const batch = db.batch();

    // Delete related records based on role
    if (userRole === 'student') {
      // Delete enrollments
      const enrollmentsSnapshot = await db.collection('enrollments')
        .where('studentId', '==', userId)
        .get();
      enrollmentsSnapshot.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Delete test attempts
      const attemptsSnapshot = await db.collection('attempts')
        .where('studentId', '==', userId)
        .get();
      attemptsSnapshot.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Delete results
      const resultsSnapshot = await db.collection('results')
        .where('studentId', '==', userId)
        .get();
      resultsSnapshot.forEach(doc => {
        batch.delete(doc.ref);
      });
    } else if (userRole === 'teacher') {
      // Teacher might have related records, but tests are already checked above
      // Delete any attempts or results where teacher is referenced if needed
    }

    // Delete the user document
    batch.delete(userDoc.ref);

    // Commit Firestore deletions
    await batch.commit();

    // Delete Firebase Authentication account
    try {
      await admin.auth().deleteUser(userId);
      console.log(`Deleted Firebase Auth account for user: ${userId}`);
    } catch (authError) {
      console.error(`Failed to delete Firebase Auth account: ${authError.message}`);
      // Continue even if auth deletion fails, user is already deleted from Firestore
    }

    return {
      success: true,
      message: `User ${userData.name} (${userRole}) deleted permanently`
    };

  } catch (error) {
    console.error('Error deleting user:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to delete user'
    );
  }
});
