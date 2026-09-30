# Firestore Security Rules for RAINTECH Online Testing System

## Overview
These security rules ensure proper data access control based on user roles (student, teacher, admin) and maintain data integrity.

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
      allow read: if isAuthenticated() && (isOwner(userId) || hasRole('admin'));
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (isOwner(userId) || hasRole('admin'));
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
  }
}
```

## Security Principles

### 1. Authentication Required
- All read and write operations require user authentication
- Unauthenticated users cannot access any data

### 2. Role-Based Access Control
- **Admin**: Full access to all collections except user passwords
- **Teacher**: Access to tests they created, their questions, and related data
- **Student**: Read access to enrolled courses, tests, and their own results

### 3. Account Status Validation
- Only active accounts (isActive == true) can access data
- Deactivated accounts are automatically blocked

### 4. Data Ownership
- Users can only modify their own data
- Teachers can only modify tests they created
- Students can only see their own attempts and results

### 5. Course Enrollment Validation
- Students can only access tests for courses they're enrolled in
- Enrollment is validated before granting test access

### 6. Immutable Data
- Test attempts cannot be modified after creation
- Ensures integrity of submission data

### 7. System-Created Data
- Results are created by the system (teachers/admin) after test submission
- Direct student creation of results is prevented

## Implementation Steps

1. **Go to Firebase Console**: Navigate to your project
2. **Firestore Database**: Select Firestore Database
3. **Rules Tab**: Click on the "Rules" tab
4. **Publish Rules**: Copy the rules above and publish them

## Testing the Rules

### Test Admin Access
```javascript
// Admin should be able to:
- Create/update/delete courses, classes, shifts
- Manage all users
- View all results
- Update results (for rankings)
```

### Test Teacher Access
```javascript
// Teacher should be able to:
- Create/update/delete their own tests
- Add/edit/delete questions for their tests
- View results for their tests
- Release results for their tests
- NOT access other teachers' data
```

### Test Student Access
```javascript
// Student should be able to:
- View their own profile
- View enrolled courses
- Take tests for enrolled courses
- View their own results
- NOT access other students' data
- NOT modify test data
```

## Security Best Practices

1. **Least Privilege Principle**: Users only get access to what they need
2. **Data Validation**: Server-side validation for all critical operations
3. **Audit Trail**: Consider adding audit logs for sensitive operations
4. **Regular Reviews**: Periodically review and update security rules
5. **Testing**: Test rules thoroughly before deploying to production

## Additional Recommendations

1. **Indexing**: Create Firestore indexes for frequently queried fields
2. **Data Validation**: Add client-side validation complementing server rules
3. **Rate Limiting**: Implement rate limiting for API calls
4. **Monitoring**: Set up monitoring for suspicious activities
5. **Backup**: Regular backups of critical data

## Deployment Checklist

- [ ] Test all user roles in development environment
- [ ] Verify enrollment-based access control
- [ ] Test result visibility before/after release
- [ ] Verify teacher ownership checks
- [ ] Test account deactivation
- [ ] Review and optimize indexes
- [ ] Set up monitoring and alerts
- [ ] Document any custom business logic exceptions
