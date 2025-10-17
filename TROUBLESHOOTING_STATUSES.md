# 🐛 Troubleshooting: Can't See Other Users' Statuses

## Quick Diagnosis Steps

### Step 1: Check Console Logs

Run your app and look for this in the console:

```
=== STATUS FETCH DEBUG ===
📦 Total statuses received from Firebase: X
👤 Current user ID: your-user-id
📋 All statuses in database:
  - User: username (userId)
    ...
```

**What to look for:**
- ✅ If you see **multiple users** → Statuses exist, check Step 2
- ⚠️ If you see **only your user** → Other users haven't created statuses
- ❌ If you see **0 statuses** → No one has created statuses yet

### Step 2: Open Debug Screen

**How to access:**
- Long press (hold 2 seconds) the **search icon** at top of home screen
- Or check console logs for detailed output

**What the debug screen shows:**
- All statuses in Firebase
- Which users have statuses
- If statuses are expired
- Your current login status

---

## Common Issues & Solutions

### Issue 1: "No statuses found in database"

**This means:** No one has created any statuses yet.

**Solution:**
```
1. Create a status from your account
2. Have a friend/another account create a status
3. Make sure you're creating status AFTER the code update
   (Old statuses in users/{userId}/statuses/ won't appear)
```

**Test with two accounts:**
1. Account A: Create a status
2. Account B: Log in and check home screen
3. Should see Account A's status

---

### Issue 2: "Firebase permission denied"

**This means:** Firebase rules not set up correctly.

**Solution:**
Go to Firebase Console → Firestore → Rules and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Statuses - top level collection
    match /statuses/{statusId} {
      // IMPORTANT: Anyone can read statuses
      allow read: if request.auth != null;
      
      // Only owner can create
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      
      // Only owner can update/delete
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Status views tracking
    match /statusViews/{viewerId} {
      allow read: if request.auth != null && request.auth.uid == viewerId;
      
      match /viewedStatuses/{statusId} {
        allow create, update: if request.auth != null && request.auth.uid == viewerId;
        allow read: if request.auth != null && request.auth.uid == viewerId;
      }
    }
  }
}
```

**Then:**
1. Click "Publish"
2. Restart your app
3. Try again

---

### Issue 3: "Statuses show as EXPIRED"

**This means:** Statuses are older than 24 hours.

**Solution:**
```
Statuses automatically expire after 24 hours (like Instagram stories).
Create a new status to test.
```

---

### Issue 4: "I see my status but not others"

**This means:** Either no other users have created statuses, or Firebase query issue.

**Debug Steps:**

1. **Check Firebase Console:**
   - Go to Firestore Database
   - Look for `statuses` collection (top level, NOT under users)
   - You should see multiple documents with different userIds
   - If you only see your userId → Other users haven't created statuses

2. **Check Console Logs:**
   ```
   📋 All statuses in database:
     - User: YourName (your-id)  ← Should see multiple lines
     - User: OtherUser (other-id)  ← Like this
   ```

3. **Create Test Status:**
   - Use a second account (different email)
   - Create a status from that account
   - Check if it appears in Firebase Console under `statuses` collection
   - Check if first account can see it

---

### Issue 5: "Error: Index required"

**This should NOT happen anymore!** Top-level collections don't need indexes.

If you see this:
1. You might have old code
2. Make sure you're querying `collection('statuses')` not `collectionGroup('statuses')`
3. Check the repository file has been updated

---

## Firebase Console Checklist

### ✅ Verify Collection Structure

1. Open Firebase Console
2. Go to Firestore Database
3. Check structure:

```
✅ CORRECT:
statuses/
  {statusId}/
    - userId: "abc123"
    - userName: "username"
    - caption: "test"
    - createdAt: timestamp
    - expiresAt: timestamp
    - mediaUrl: "..."
    - mediaType: "image"

❌ WRONG (old structure):
users/
  {userId}/
    statuses/
      {statusId}/
```

### ✅ Check Multiple Users

In the `statuses` collection, you should see:
- Documents with different `userId` values
- Recent timestamps (not expired)
- Valid data in all fields

---

## Step-by-Step Test

### Test 1: Single User (Your Account)

1. **Create a status:**
   - Open app
   - Tap "Add status"
   - Select image
   - Add caption
   - Create

2. **Check Firebase:**
   - Open Firebase Console
   - Go to Firestore → statuses collection
   - You should see 1 document with your userId

3. **Check Home Screen:**
   - Your status should appear with green border
   - Says "My status" at bottom

**Expected:** ✅ Your status shows

---

### Test 2: Multiple Users

1. **Account A: Create status**
   - Log in with Account A
   - Create a status
   - Should see it on home screen (green border)

2. **Check Firebase:**
   - Firestore → statuses collection
   - Should see Account A's status

3. **Account B: View status**
   - Log out of Account A
   - Log in with Account B
   - Check home screen
   - **Should see Account A's status with BLUE border**

**Expected:** 
- ✅ Account B sees Account A's status
- ✅ Blue border (unseen status)
- ✅ Can tap to view

---

## Quick Fixes

### If Console Shows "0 statuses received":

```
Problem: Query returning empty
Solutions:
1. Check Firebase rules (see Issue 2 above)
2. Create a status to populate database
3. Verify you're logged in (check currentUser)
```

### If Console Shows "only your status":

```
Problem: Other users haven't created statuses
Solutions:
1. Use second account to create status
2. Make sure second account created status AFTER code update
3. Check Firebase Console to verify status exists
```

### If Status Shows in Firebase but not in app:

```
Problem: Query or filtering issue
Solutions:
1. Check console logs for detailed output
2. Verify status is not expired (check expiresAt field)
3. Check if status was created in old location
4. Restart app to refresh
```

---

## Manual Firebase Query Test

To test if Firebase query works:

1. Open Firebase Console
2. Go to Firestore
3. Click on `statuses` collection
4. You should see all status documents
5. Check if multiple users' statuses are there

If statuses exist but app doesn't show them:
- Check Firebase rules (permission issue)
- Check console logs for errors
- Restart app

---

## Get Help

If still not working, provide these details:

1. **Console output** (copy the DEBUG section)
2. **Firebase Console screenshot** showing `statuses` collection
3. **Number of accounts** you're testing with
4. **When statuses were created** (before or after update)

---

## Expected Console Output

When working correctly, you should see:

```
📡 Fetching all statuses...
=== STATUS FETCH DEBUG ===
📦 Total statuses received from Firebase: 2
👤 Current user ID: abc123

📋 All statuses in database:
  - User: YourName (abc123)
    Caption: test
    Created: 2025-01-15 10:00:00
    Expired: false
    Is current user: true
  - User: FriendName (xyz789)
    Caption: hello
    Created: 2025-01-15 09:30:00
    Expired: false
    Is current user: false

👥 Grouped statuses from 2 users
   Users with statuses: abc123 (YOU), xyz789

✅ Successfully loaded 2 status groups
   Current user has status: true
   Other users with statuses: 1

📊 Status groups created:
  - YourName (YOU)
    Status count: 1
    Has unseen: false
  - FriendName (Other User)
    Status count: 1
    Has unseen: true
=== END DEBUG ===
```

This output confirms everything is working! 🎉

