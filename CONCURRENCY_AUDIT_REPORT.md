# RAINTECH SMART TEST - Concurrency Audit Report
**Date**: 2026-10-14
**Target**: 60 concurrent students taking the same test simultaneously
**Platforms**: Windows, Chrome Web, Android

---

## Executive Summary

**CRITICAL FINDING**: The application is **NOT READY** for 60 concurrent students. Several critical concurrency and performance issues will cause failures, data corruption, and incorrect rankings under load.

**Risk Level**: HIGH
**Recommendation**: Fix critical issues before load testing

---

## Critical Issues Identified

### 1. ⚠️ CRITICAL: Ranking Calculation Race Condition
**Location**: `lib/controllers/result_controller.dart:246-275`

**Problem**:
```dart
Future<bool> calculateRankings({required String testId}) async {
  await fetchTestResults(testId: testId);
  results.sort((a, b) => b.obtainedMarks.compareTo(a.obtainedMarks));
  
  int currentPosition = 1;
  for (int i = 0; i < results.length; i++) {
    // CRITICAL: Sequential writes without locking
    await _firestoreService.updateDocument(
      collectionPath: 'results',
      documentId: results[i].id!,
      data: {'position': currentPosition},
    );
  }
}
```

**Impact**:
- If 60 students submit within 1-2 seconds, this function is called 60 times simultaneously
- Each call fetches all results, sorts them, then writes to N documents sequentially
- **Write conflicts**: Multiple processes updating the same documents concurrently
- **Incorrect rankings**: Positions will be calculated on stale data
- **Performance bottleneck**: O(N) sequential writes per submission

**Severity**: CRITICAL - Will cause data corruption and incorrect rankings

---

### 2. ⚠️ CRITICAL: No Duplicate Submission Protection at Database Level
**Location**: `lib/views/student/test_screen.dart:42-58`

**Problem**:
```dart
final hasAttempted = await _attemptController.hasStudentAttemptedTest(
  testId: _test!.id!,
  studentId: _authController.currentUser!.id!,
);

if (hasAttempted) {
  // Block reattempt
}
```

**Issues**:
- Check is performed at test start, not at submission
- No Firestore security rule or unique constraint preventing duplicate attempts
- Race condition: Multiple tabs/devices could both pass the check simultaneously
- Check queries all attempts for student, then filters by testId - inefficient

**Impact**:
- Students could submit the same test multiple times via multiple devices/tabs
- Duplicate result records
- Corrupted rankings

**Severity**: CRITICAL - Allows duplicate submissions

---

### 3. ⚠️ HIGH: No Firestore Transactions for Critical Operations
**Location**: `lib/controllers/exam_controller.dart:85-131`

**Problem**:
```dart
Future<bool> submitExam({required String studentId}) async {
  if (isSubmitted.value) return false; // Client-side only
  
  // No transaction wrapping attempt + result
  await _firestoreService.addDocument(
    collectionPath: 'attempts',
    data: attempt.toJson(),
  );
}
```

**Impact**:
- Race condition between attempt check and attempt creation
- If network fails after attempt save but before result save, data inconsistency
- No atomicity guarantee

**Severity**: HIGH - Data integrity risk

---

### 4. ⚠️ HIGH: Ranking Calculation Triggered on Every Submission
**Location**: `lib/controllers/result_controller.dart:234-235`

**Problem**:
```dart
await _firestoreService.addDocument(
  collectionPath: 'results',
  data: result.toJson(),
);

// Auto-calculate rankings after saving result
await calculateRankings(testId: testId);
```

**Impact**:
- With 60 students submitting simultaneously, this function runs 60 times
- Each call does:
  - 1 read: fetch all results for test
  - N writes: update position for each result
- For 60 students: 60 reads + 60 × 60 = 3,600 writes in short window
- **Firestore write limit**: 1 write/second per document will be hit

**Severity**: HIGH - Will cause Firestore write quota errors

---

### 5. ⚠️ MEDIUM: No Composite Indexes for Common Queries
**Location**: Multiple locations

**Common Query Patterns**:
```dart
// AttemptController:204-231
queryWhereEqualTo(collectionPath: 'attempts', field: 'studentId', value: studentId)
// Then filter by testId in code

// ResultController:90-116
queryWhereEqualTo(collectionPath: 'results', field: 'testId', value: testId)
```

**Problem**:
- No composite index on `(testId, studentId)` for attempts
- No composite index on `(testId, submittedAt)` for results
- Queries that need to filter by multiple fields are inefficient

**Impact**:
- Slower query performance under load
- Higher Firestore read costs
- Potential timeout for complex queries

**Severity**: MEDIUM - Performance degradation

---

### 6. ⚠️ MEDIUM: Synchronous Question Loading for Each Test Start
**Location**: `lib/views/student/test_screen.dart:60`

**Problem**:
```dart
await _questionController.fetchQuestionsByTest(testId: _test!.id!);
```

**Impact**:
- 60 students starting test simultaneously = 60 concurrent reads on questions collection
- No caching mechanism
- Questions are read every time, even though they don't change during a test

**Severity**: MEDIUM - Performance degradation

---

### 7. ⚠️ LOW: No Rate Limiting on Test Submission
**Location**: `lib/controllers/exam_controller.dart:85`

**Problem**:
- No rate limiting on submission endpoint
- Client-side `isSubmitted` flag can be bypassed

**Impact**:
- Potential for submission spam
- Minor issue for legitimate use case

**Severity**: LOW - Minor security concern

---

## Firestore Quota Analysis

### Current Usage (Estimated)
**Per Test Submission**:
- 1 write: Save attempt to `attempts` collection
- 1 write: Save result to `results` collection
- 1 read: Check existing attempts
- 1 read: Fetch questions
- **Ranking**: 1 read + N writes (where N = number of submissions)

**For 60 Simultaneous Submissions**:
- **Without ranking fixes**: 
  - 120 writes (attempts + results)
  - 120 reads (attempts check + questions)
  - **With ranking**: 60 reads + 3,600 writes (catastrophic)

### Firestore Limits (Spark Plan)
- **Writes**: 20,000/day → 333/hour → 5.5/minute
- **Reads**: 50,000/day → 833/hour → 13.9/minute
- **Storage**: 5GB

**Problem**: 60 simultaneous submissions would exceed Spark plan limits in seconds

---

## Security Risks

### 1. Client-Side Duplicate Check
- **Risk**: Students can bypass by opening multiple tabs
- **Impact**: Duplicate submissions, corrupted data
- **Fix Needed**: Firestore security rule with unique constraint

### 2. No Server-Side Validation
- **Risk**: Manipulated submissions via modified client
- **Impact**: Incorrect scores, cheating
- **Fix Needed**: Cloud Functions for scoring validation

### 3. No Authorization Check on Attempts
- **Risk**: Students could submit for other students
- **Impact**: Data corruption
- **Fix Needed**: Firestore security rules

---

## Performance Bottlenecks

### 1. Ranking Calculation (CRITICAL)
- **Current**: O(N) sequential writes per submission
- **Under Load**: 60 × 60 = 3,600 concurrent writes
- **Fix**: Move to Cloud Functions, use batched writes, or defer ranking

### 2. Duplicate Attempt Check (HIGH)
- **Current**: Query all attempts, filter in code
- **Under Load**: 60 students × check on each submission = many redundant reads
- **Fix**: Composite index + Firestore security rule

### 3. Question Loading (MEDIUM)
- **Current**: Fetch questions for each test start
- **Under Load**: 60 concurrent reads
- **Fix**: Client-side caching or preload

---

## Required Fixes

### CRITICAL PRIORITY (Must Fix Before Load Testing)

#### Fix 1: Implement Atomic Duplicate Submission Prevention
**Approach**: Use Firestore security rules with unique constraint

```javascript
// Firestore Security Rules
match /attempts/{attemptId} {
  allow create: if request.auth != null 
    && request.resource.data.studentId == request.auth.uid
    && !exists(/databases/$(database)/documents/attempts/$(attemptId))
    // Add check for existing (testId, studentId) combination
}
```

**Better Approach**: Use Firestore transactions to check-and-set atomically

```dart
Future<bool> submitExamWithLock({required String studentId, required String testId}) async {
  return await _firestore.runTransaction((transaction) async {
    // Check for existing attempt atomically
    final existingAttempts = await transaction.get(
      _firestore.collection('attempts')
        .where('studentId', isEqualTo: studentId)
        .where('testId', isEqualTo: testId)
        .limit(1)
    );
    
    if (existingAttempts.docs.isNotEmpty) {
      throw Exception('Already attempted');
    }
    
    // Create attempt atomically
    transaction.set(attemptRef, attemptData);
  });
}
```

---

#### Fix 2: Fix Ranking Calculation Architecture
**Option A**: Defer ranking calculation (Recommended)
- Don't calculate rankings on every submission
- Trigger ranking calculation only when teacher releases results
- Reduces writes from 3,600 to 60

**Option B**: Use Cloud Functions
- Move ranking to server-side Cloud Function
- Use Firestore triggers on result creation
- Batch writes for efficiency

**Option C**: Client-side batched ranking
- Use batched writes instead of sequential
- Still has race condition issues

**Recommended**: Option A - Defer ranking until results release

---

#### Fix 3: Add Firestore Transactions for Critical Operations
```dart
Future<bool> submitExamAtomic({required String studentId, required String testId}) async {
  try {
    await _firestore.runTransaction((transaction) async {
      // 1. Check for existing attempt
      final existingQuery = _firestore.collection('attempts')
          .where('studentId', isEqualTo: studentId)
          .where('testId', isEqualTo: testId)
          .limit(1);
      final existingSnapshot = await existingQuery.get();
      
      if (existingSnapshot.docs.isNotEmpty) {
        throw Exception('Test already attempted');
      }
      
      // 2. Create attempt
      final attemptRef = _firestore.collection('attempts').doc();
      transaction.set(attemptRef, attemptData);
      
      // 3. Create result
      final resultRef = _firestore.collection('results').doc();
      transaction.set(resultRef, resultData);
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

---

### HIGH PRIORITY

#### Fix 4: Add Composite Indexes
Create indexes in Firebase Console:

**Index 1**: Attempts by (studentId, testId)
```
Collection: attempts
Fields:
  - studentId (ascending)
  - testId (ascending)
```

**Index 2**: Results by (testId, submittedAt)
```
Collection: results
Fields:
  - testId (ascending)
  - submittedAt (descending)
```

---

#### Fix 5: Implement Client-Side Question Caching
```dart
class QuestionController {
  final Map<String, List<QuestionModel>> _cache = {};
  
  Future<void> fetchQuestionsByTest({required String testId}) async {
    if (_cache.containsKey(testId)) {
      questions.value = _cache[testId]!;
      return;
    }
    
    // Fetch from Firestore
    // ...
    _cache[testId] = questions.toList();
  }
}
```

---

### MEDIUM PRIORITY

#### Fix 6: Add Retry Logic with Exponential Backoff
```dart
Future<bool> submitWithRetry({required String studentId, required String testId}) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      return await submitExamAtomic(studentId: studentId, testId: testId);
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempts * 2));
    }
  }
  return false;
}
```

---

#### Fix 7: Add Loading States and Error Handling
- Show proper loading indicators during submission
- Handle network errors gracefully
- Allow retry on failure

---

## Load Testing Plan

### Test Environment Setup

#### 1. Create Test Project
**DO NOT** use production Firebase project `raintech-smart-test`

Steps:
1. Create new Firebase project: `raintech-smart-test-load-test`
2. Copy Firestore data structure (tests, questions, users)
3. Create 60 test student accounts
4. Create 1 test with 20 questions
5. Set Firebase project to Blaze plan (for load testing)

#### 2. Load Test Tool Options

**Option A**: Manual Testing (Low fidelity)
- Use 60 actual devices/emulators
- Script test submission timing
- Manually coordinate start time

**Option B**: Automated Script (Medium fidelity)
- Create Flutter test script
- Use multiple simulated users
- Test from single machine

**Option C**: Professional Load Testing (High fidelity)
- Use tools like k6, Locust, or Firebase Performance Monitoring
- Simulate realistic network conditions
- Measure response times, error rates

**Recommended**: Start with Option B for basic validation

---

### Test Scenarios

#### Scenario 1: Simultaneous Test Start
**Objective**: Verify 60 students can start test simultaneously

**Steps**:
1. All 60 students login
2. All 60 students click "Start Test" within 5 seconds
3. Monitor:
   - Question loading time
   - Firestore read operations
   - Error rate

**Success Criteria**:
- All students load questions within 10 seconds
- < 5% error rate
- No Firestore quota errors

---

#### Scenario 2: Simultaneous Submission
**Objective**: Verify 60 students can submit simultaneously

**Steps**:
1. All 60 students start test
2. All students answer all questions
3. All students submit within 5 seconds
4. Monitor:
   - Attempt creation
   - Result calculation
   - Ranking calculation
   - Firestore write operations

**Success Criteria**:
- All submissions succeed
- No duplicate attempts
- Rankings calculated correctly
- < 5% error rate

---

#### Scenario 3: Staggered Submission
**Objective**: Verify handling of continuous submissions

**Steps**:
1. 60 students start test
2. Students submit continuously over 10 minutes
3. Monitor:
   - Attempt/result creation rate
   - Ranking calculation frequency
   - Firestore operation queue

**Success Criteria**:
- All submissions succeed
- No write conflicts
- Rankings updated correctly

---

#### Scenario 4: Network Interruption
**Objective**: Verify graceful handling of network issues

**Steps**:
1. 30 students submit with good network
2. 30 students submit with simulated poor network
3. Monitor:
   - Retry behavior
   - Data integrity
   - User experience

**Success Criteria**:
- No data corruption
- Proper error messages
- Successful retry on network recovery

---

#### Scenario 5: Cross-Platform Concurrency
**Objective**: Verify Windows, Web, and Android work together

**Steps**:
1. 20 students on Windows
2. 20 students on Chrome Web
3. 20 students on Android
4. All submit simultaneously
5. Monitor:
   - Platform-specific issues
   - Synchronization
   - Data consistency

**Success Criteria**:
- All platforms function correctly
- No platform-specific bugs
- Consistent data across platforms

---

### Metrics to Monitor

#### Firestore Metrics
- **Read Operations**: Total reads per second
- **Write Operations**: Total writes per second
- **Document Reads**: Reads per collection
- **Document Writes**: Writes per collection
- **Quota Usage**: Percentage of daily quota used

#### Application Metrics
- **Submission Success Rate**: Percentage of successful submissions
- **Submission Latency**: Time from submit to completion
- **Error Rate**: Percentage of failed operations
- **Duplicate Attempts**: Number of duplicate submissions

#### Data Integrity Metrics
- **Attempt Count**: Should equal number of students
- **Result Count**: Should equal number of students
- **Ranking Accuracy**: Positions should match scores
- **Score Accuracy**: Scores should match expected values

---

### Success Criteria

**Minimum Requirements**:
- ✅ 60 students can start test simultaneously
- ✅ 60 students can submit test simultaneously
- ✅ Zero duplicate submissions
- ✅ All scores calculated correctly
- ✅ Rankings calculated correctly
- ✅ No Firestore quota errors
- ✅ No data corruption
- ✅ < 5% error rate
- ✅ < 10 second submission latency

**Stretch Goals**:
- ✅ Submission latency < 5 seconds
- ✅ Error rate < 1%
- ✅ Handles 100 concurrent students

---

## Bottleneck Summary

| Bottleneck | Severity | Impact | Fix Required |
|------------|----------|--------|--------------|
| Ranking calculation race condition | CRITICAL | Data corruption, incorrect rankings | Yes - defer ranking |
| No duplicate submission protection | CRITICAL | Duplicate submissions | Yes - Firestore transactions |
| No atomic operations | HIGH | Data integrity risk | Yes - transactions |
| Ranking on every submission | HIGH | Write quota errors | Yes - defer ranking |
| No composite indexes | MEDIUM | Performance degradation | Yes - add indexes |
| No question caching | MEDIUM | Performance degradation | Optional - add caching |
| No rate limiting | LOW | Minor security risk | Optional - add rate limiting |

---

## Implementation Priority

### Phase 1: Critical Fixes (Required Before Load Testing)
1. ✅ Implement Firestore transactions for submission
2. ✅ Defer ranking calculation to results release
3. ✅ Add duplicate submission prevention
4. ✅ Add composite indexes

### Phase 2: High Priority (Recommended)
5. ✅ Add retry logic with exponential backoff
6. ✅ Improve error handling
7. ✅ Add loading states

### Phase 3: Medium Priority (Optional)
8. ✅ Add question caching
9. ✅ Add rate limiting
10. ✅ Add Firestore security rules

---

## Conclusion

**The application is NOT READY for 60 concurrent students.**

**Critical issues that MUST be fixed**:
1. Ranking calculation architecture (O(N²) write problem)
2. No duplicate submission protection at database level
3. No atomic operations for critical operations

**After fixes**, the application should handle 60 concurrent students with:
- Proper data integrity
- Correct rankings
- Acceptable performance
- No quota errors (on Blaze plan)

**DO NOT** claim 60-student support until load testing passes all scenarios.

---

## Next Steps

1. Implement Phase 1 critical fixes
2. Create test Firebase project
3. Set up load test environment
4. Run load test scenarios
5. Monitor metrics
6. Fix any issues found
7. Re-test until all criteria pass
8. Only then claim 60-student support
