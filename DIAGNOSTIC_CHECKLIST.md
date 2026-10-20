# Diagnostic Checklist: Questions Not Loading

## Current Issue
Student sees "No Questions Available" message when trying to take a published test.

## Immediate Actions Required

### 1. CHECK: Have you deployed the updated Firestore rules?

**This is the most likely cause!** The rules fix is in the file but not yet deployed to Firebase.

**Steps to deploy:**
1. Open Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Go to Firestore Database → Rules tab
4. Copy the rules from `FIRESTORE_RULES.md` file in your project
5. Paste them into the Firebase Console rules editor
6. Click "Publish"

**Without this step, students CANNOT read questions even if they exist!**

### 2. CHECK: Does the test actually have questions in the database?

**Option A: Check via Firebase Console**
1. Go to Firebase Console → Firestore Database
2. Navigate to `questions` collection
3. Click "Add filter" → Filter by `testId` → Enter your test ID
4. See if any documents appear

**Option B: Check via app logs**
1. Run the app with the enhanced debugging I just added
2. Try to take the test as a student
3. Check the console/debug output for:
   - "Test Question Count: X" (from test document)
   - "Query returned X documents" (from questions query)
   - If query returns 0 but test.questionCount > 0, questions exist but can't be read

### 3. CHECK: Is the test actually published?

1. Go to Firebase Console → Firestore Database → `tests` collection
2. Find your test document
3. Check the `status` field
4. It should be `"published"` (not `"draft"` or `"closed"`)

If it's not published:
- Log in as a teacher
- Go to Teacher Tests screen
- Click "Publish" on the test

### 4. CHECK: Is the student enrolled in the test's course?

1. Go to Firebase Console → Firestore Database → `enrollments` collection
2. Look for enrollment with:
   - `studentId` = student's Firebase UID
   - `courseId` = test's courseId
   - `status` = `"active"`

If enrollment doesn't exist or is not active:
- Log in as student
- Go to Student Courses
- Enroll in the course

### 5. CHECK: Enhanced Debug Output

I've added detailed debugging. When you try to take the test, check the console output:

```
DEBUG: ==================================
DEBUG: Loading test - Test ID: XXX
DEBUG: Test Title: XXX
DEBUG: Test Status: published
DEBUG: Test Course ID: XXX
DEBUG: Test Question Count: 20
DEBUG: ==================================
DEBUG: Fetching questions for test XXX...
DEBUG: Executing Firestore query...
DEBUG: Query returned 0 documents
DEBUG: WARNING - No documents found in questions collection for testId: XXX
```

**Interpretation:**
- If `Test Question Count: 20` but `Query returned 0 documents`:
  - Questions don't exist in database OR
  - Firestore rules are blocking access (most likely if rules not deployed)

- If `Test Question Count: 0`:
  - Test was created but no questions were added
  - Teacher needs to add questions to the test

## Most Likely Scenarios

### Scenario 1: Rules Not Deployed (90% likely)
**Symptoms:**
- Test shows as published
- Test has questions in database (check via Firebase Console)
- Student can see test in Available Tests
- But query returns 0 documents for student

**Solution:**
Deploy the Firestore rules from `FIRESTORE_RULES.md` to Firebase Console

### Scenario 2: Test Has No Questions (8% likely)
**Symptoms:**
- Test shows in Available Tests
- `Test Question Count: 0` in debug output
- Firebase Console shows no documents in `questions` collection for this testId

**Solution:**
Teacher needs to add questions to the test before publishing

### Scenario 3: Student Not Enrolled (2% likely)
**Symptoms:**
- Debug shows "Is enrolled in course: false"
- Student doesn't see test in Available Tests (but if they do, this isn't the issue)

**Solution:**
Student needs to enroll in the course

## Quick Test Steps

1. **Deploy Firestore rules** (CRITICAL - most likely the issue)
2. Hot restart the Flutter app
3. Try to take the test as student
4. Check console output
5. Share the debug output if still not working

## What to Share If Still Not Working

If after deploying rules the issue persists, share:
1. Console debug output when trying to take the test
2. Screenshot of Firebase Console showing:
   - Test document (from `tests` collection)
   - Questions filtered by testId (from `questions` collection)
   - Student enrollment (from `enrollments` collection)
