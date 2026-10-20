# Secret Code Authentication Deployment Guide

## Overview
This document provides step-by-step instructions for deploying the secure secret code authentication system for RAINTECH SMART TEST.

## Prerequisites

1. Firebase project with existing configuration
2. Firebase CLI installed
3. Node.js (v18 or higher) for Cloud Functions
4. Flutter development environment

## Deployment Steps

### Step 1: Update Dependencies

The Flutter dependencies have already been updated in `pubspec.yaml`:
- Added `crypto: ^3.0.3` for secret code generation
- Added `cloud_functions: ^5.6.2` for Cloud Functions integration

Run:
```bash
flutter pub get
```

### Step 2: Deploy Firebase Cloud Functions

1. Navigate to the `firebase_functions` directory:
```bash
cd firebase_functions
```

2. Install dependencies:
```bash
npm install
```

3. Login to Firebase (if not already logged in):
```bash
firebase login
```

4. Initialize Firebase Functions (if not already done):
```bash
firebase init functions
```
- Select your existing Firebase project
- Choose JavaScript as the language
- Select Node.js 18

5. Deploy the functions:
```bash
firebase deploy --only functions
```

6. Verify deployment:
- Go to Firebase Console → Functions
- Confirm `verifySecretCode` and `cleanupRateLimits` are deployed

### Step 3: Update Firestore Security Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Replace the existing rules with the content from `FIRESTORE_RULES_UPDATED.md`
3. Click "Publish"

**Key Security Changes:**
- Users cannot modify their `secretCode` after creation
- Users cannot modify their `role`
- `rate_limits` collection is only accessible by Cloud Functions
- Admin can view and modify secret codes

### Step 4: Test the Implementation

#### Test Student Signup

1. Navigate to Student Signup screen
2. Fill in the registration form
3. Submit the form
4. Verify:
   - Secret code is generated and displayed
   - Code format is `RTS-STU-XXXXXXXX` (14 characters)
   - Copy button works
   - Account is created with `approvalStatus: 'pending'`

#### Test Teacher Signup

1. Navigate to Teacher Signup screen
2. Fill in the registration form
3. Submit the form
4. Verify:
   - Secret code is generated and displayed
   - Code format is `RTS-TCH-XXXXXXXX` (14 characters)
   - Copy button works
   - Account is created with `approvalStatus: 'pending'`

#### Test Email/Password Login

1. Navigate to Login screen
2. Select "Email" login method
3. Enter email and password
4. Verify:
   - Existing email/password login still works
   - Pending approval users are blocked
   - Approved users can access their portal

#### Test Secret Code Login

1. Navigate to Login screen
2. Select "Secret Code" login method
3. Enter a valid secret code
4. Verify:
   - Valid secret code authenticates the user
   - User is navigated to correct portal
   - Pending approval users are blocked with message: "Admin Approved you and then enter"
   - Rejected users are blocked

#### Test Invalid Secret Codes

1. Try an invalid format (e.g., "INVALID-CODE")
2. Verify error message: "Invalid secret code format"
3. Try a non-existent secret code
4. Verify error message: "Invalid secret code"
5. Try an admin secret code (if any)
6. Verify error message: "Invalid secret code or role not allowed"

#### Test Rate Limiting

1. Enter 5 invalid secret codes in quick succession
2. Verify error message: "Too many attempts. Please try again later"
3. Wait 15 minutes
4. Verify attempts are allowed again

#### Test Existing Features

Verify all existing features still work:
- Student portal access
- Teacher portal access
- Admin portal access
- Test creation and publishing
- Test submission
- Results and marksheets
- Profile editing
- Photo upload

## Manual Deployment Checklist

- [ ] Flutter dependencies updated (`flutter pub get`)
- [ ] Cloud Functions dependencies installed (`npm install` in firebase_functions)
- [ ] Cloud Functions deployed (`firebase deploy --only functions`)
- [ ] Firestore security rules updated in Firebase Console
- [ ] Student signup tested with secret code generation
- [ ] Teacher signup tested with secret code generation
- [ ] Email/password login tested
- [ ] Secret code login tested
- [ ] Invalid secret codes tested
- [ ] Rate limiting tested
- [ ] Pending approval flow tested
- [ ] Existing features verified

## Important Notes

### Secret Code Security

1. **Never expose secret codes publicly**
   - Secret codes are only shown to the user during signup
   - They are stored in Firestore but protected by security rules
   - Only Admin can view secret codes in Firestore

2. **Unique Code Generation**
   - The system generates unique codes using random alphanumeric characters
   - Duplicate prevention is enforced by checking Firestore before assignment
   - Maximum 10 retry attempts for code generation

3. **Code Format**
   - Student codes: `RTS-STU-XXXXXXXX` (14 characters)
   - Teacher codes: `RTS-TCH-XXXXXXXX` (14 characters)
   - Characters: A-Z (excluding I, O) and 2-9 (excluding 0, 1)

### Cloud Functions

1. **verifySecretCode**
   - Validates secret code format
   - Verifies role from code prefix
   - Checks account status and approval
   - Implements rate limiting (5 attempts per 15 minutes)
   - Returns user data without sensitive information

2. **cleanupRateLimits**
   - Scheduled function running every hour
   - Cleans up old rate limit entries
   - Keeps only recent attempts (within 15 minutes)

### Firestore Collections

1. **users**
   - Added `secretCode` field
   - Protected by security rules
   - Users cannot modify their secret code or role

2. **rate_limits** (new)
   - Stores IP address and attempt history
   - Only accessible by Cloud Functions
   - Automatically cleaned up every hour

## Troubleshooting

### Cloud Functions Deployment Fails

**Issue:** Error during `firebase deploy --only functions`

**Solution:**
1. Ensure Firebase CLI is authenticated: `firebase login`
2. Check Node.js version: `node --version` (should be v18+)
3. Reinstall dependencies: `cd firebase_functions && rm -rf node_modules && npm install`
4. Check Firebase project is selected: `firebase projects:list`

### Secret Code Login Fails

**Issue:** Error "Failed to verify secret code"

**Solution:**
1. Verify Cloud Functions are deployed
2. Check Firebase Console → Functions for errors
3. Verify secret code format (14 characters, correct prefix)
4. Check user has valid `approvalStatus` in Firestore
5. Check user `isActive` is true in Firestore

### Rate Limiting Too Aggressive

**Issue:** Users get locked out too quickly

**Solution:**
1. Adjust `MAX_ATTEMPTS` in `firebase_functions/index.js` (default: 5)
2. Adjust `ATTEMPT_WINDOW_MS` in `firebase_functions/index.js` (default: 15 minutes)
3. Redeploy functions: `firebase deploy --only functions`

### Secret Code Not Unique

**Issue:** Error "Failed to generate unique secret code"

**Solution:**
1. This is rare but possible with many users
2. The system retries up to 10 times
3. If it fails, the user should try signing up again
4. Consider increasing retry limit in `AuthController.signUp()`

## Security Best Practices

1. **Never hardcode secret codes** - Always generate them dynamically
2. **Never expose secret codes in logs** - The system doesn't log secret codes
3. **Use HTTPS** - All Cloud Functions calls are encrypted
4. **Monitor suspicious activity** - Check Cloud Functions logs regularly
5. **Regular security audits** - Review security rules periodically
6. **Keep dependencies updated** - Run `flutter pub upgrade` and `npm update` regularly

## Support

If you encounter issues:
1. Check Firebase Console logs for errors
2. Review Firestore security rules
3. Verify Cloud Functions are deployed
4. Check Flutter console for runtime errors
5. Ensure all dependencies are up to date

## References

- Firebase Cloud Functions: https://firebase.google.com/docs/functions
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/rules
- Flutter Cloud Functions: https://firebase.flutter.dev/docs/functions/overview
