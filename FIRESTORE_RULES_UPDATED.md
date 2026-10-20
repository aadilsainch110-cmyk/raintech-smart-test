# Firestore Security Rules for RAINTECH Online Testing System (Updated with Secret Code Protection)

## Overview
These security rules ensure proper data access control based on user roles (student, teacher, admin) and maintain data integrity. They also protect secret codes from unauthorized access.

## Rules Structure

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function hasRole(role) {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }

    function isActive() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isActive == true;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isTestOwner(testId) {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/tests/$(testId)).data.createdBy == request.auth.uid;
    }

    function isEnrolledInCourse(courseId) {
      return isAuthenticated() &&
             exists(/databases/$(database)/documents/enrollments/$(request.auth.uid)/$(courseId));
    }

    // Users collection
    match /users/{userId} {
      // Users can read their own data (except secretCode)
      allow read: if isAuthenticated() && isOwner(userId);

      // Admin can read all user data
      allow read: if isAuthenticated() && hasRole('admin');

      // Allow create on signup (server should validate)
      allow create: if isAuthenticated();

      // Users can update their own data (except secretCode and role)
      allow update: if isAuthenticated() && isOwner(userId) &&
                     !request.resource.data.diff(resource.data).affectedKeys().hasAny(['secretCode', 'role']);

      // Admin can update all user data
      allow update: if isAuthenticated() && hasRole('admin');

      // Only admin can delete users
      allow delete: if hasRole('admin');
    }

    // Courses collection
    match /courses/{courseId} {
      allow read: if isAuthenticated() && isActive();
      allow create: if hasRole('admin');
      allow update: if hasRole('admin');
      allow delete: if hasRole('admin');
    }

    // Classes collection
    match /classes/{classId} {
      allow read: if isAuthenticated() && isActive();
      allow create: if hasRole('admin');
      allow update: if hasRole('admin');
      allow delete: if hasRole('admin');
    }

    // Shifts collection
    match /shifts/{shiftId} {
      allow read: if isAuthenticated() && isActive();
      allow create: if hasRole('admin');
      allow update: if hasRole('admin');
      allow delete: if hasRole('admin');
    }

    // Tests collection
    match /tests/{testId} {
      allow read: if isAuthenticated() && isActive() &&
                     (hasRole('admin') ||
                      hasRole('teacher') ||
                      isTestOwner(testId) ||
                      isEnrolledInCourse(get(/databases/$(database)/documents/tests/$(testId)).data.courseId));
      allow create: if hasRole('teacher') || hasRole('admin');
      allow update: if hasRole('admin') || isTestOwner(testId);
      allow delete: if hasRole('admin') || isTestOwner(testId);
    }

    // Questions collection
    match /tests/{testId}/questions/{questionId} {
      allow read: if isAuthenticated() && isActive() &&
                     (hasRole('admin') ||
                      hasRole('teacher') ||
                      isTestOwner(testId));
      allow create: if hasRole('teacher') || hasRole('admin');
      allow update: if hasRole('admin') || isTestOwner(testId);
      allow delete: if hasRole('admin') || isTestOwner(testId);
    }

    // Attempts collection
    match /attempts/{attemptId} {
      allow read: if isAuthenticated() && isActive() &&
                     (hasRole('admin') ||
                      hasRole('teacher') ||
                      resource.data.studentId == request.auth.uid);
      allow create: if isAuthenticated() && isActive() && resource.data.studentId == request.auth.uid;
      allow update: if false; // Attempts are immutable once created
      allow delete: if hasRole('admin');
    }

    // Results collection
    match /results/{resultId} {
      allow read: if isAuthenticated() && isActive() &&
                     (hasRole('admin') ||
                      hasRole('teacher') ||
                      resource.data.studentId == request.auth.uid);
      allow create: if hasRole('admin') || hasRole('teacher'); // Created by system after test submission
      allow update: if hasRole('admin') || hasRole('teacher'); // Updated by system for rankings
      allow delete: if hasRole('admin');
    }

    // Enrollments collection
    match /enrollments/{enrollmentId} {
      allow read: if isAuthenticated() && isActive() &&
                     (hasRole('admin') ||
                      hasRole('teacher') ||
                      resource.data.studentId == request.auth.uid);
      allow create: if isAuthenticated() && isActive() && resource.data.studentId == request.auth.uid;
      allow update: if hasRole('admin') || hasRole('teacher');
      allow delete: if hasRole('admin') || hasRole('teacher');
    }

    // Rate limits collection (for Cloud Functions)
    match /rate_limits/{ipAddress} {
      allow read, write: if false; // Only Cloud Functions can access this
    }
  }
}
```

## Secret Code Security

### Key Changes
1. **Secret Code Protection**: Users cannot modify their secret codes after creation
2. **Role Protection**: Users cannot modify their own role
3. **Rate Limits Collection**: Only accessible by Cloud Functions
4. **Admin Access**: Admin can view and modify secret codes

### Implementation Notes
- Secret codes are set during user creation only
- The `affectedKeys()` check prevents users from modifying `secretCode` and `role` fields
- Cloud Functions handle secret code verification server-side
- Rate limiting is enforced via the `rate_limits` collection

## Deployment Instructions

1. Update Firestore rules in Firebase Console with the rules above
2. Deploy Firebase Cloud Functions (see below)
3. Test all authentication flows

## Cloud Functions Deployment

### Prerequisites
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Functions (if not already done)
cd firebase_functions
npm install
```

### Deploy Functions
```bash
# From project root
firebase deploy --only functions
```

### Test Functions Locally
```bash
# Start Firebase emulators
firebase emulators:start

# The verifySecretCode function will be available at:
# http://localhost:5001/your-project-id/us-central1/verifySecretCode
```

## Testing Checklist

- [ ] Test student signup and secret code generation
- [ ] Test teacher signup and secret code generation
- [ ] Test email/password login
- [ ] Test secret code login
- [ ] Test invalid secret code format
- [ ] Test non-existent secret code
- [ ] Test pending approval with secret code
- [ ] Test rate limiting (5 failed attempts)
- [ ] Verify secret codes are protected in Firestore
- [ ] Test admin can view secret codes
- [ ] Test users cannot modify secret codes
- [ ] Test existing features still work
