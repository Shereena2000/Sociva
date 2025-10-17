# Firebase Status Setup Guide (Updated - Top-Level Collection)

## ✅ Good News: No Firebase Index Required!

The status feature now uses a **top-level collection** (standard for social media apps). This means:
- ✅ No complex Firebase indexes needed
- ✅ Simple queries
- ✅ Better performance
- ✅ Industry standard structure

---

## Firebase Database Structure (NEW)

### Top-Level Collection Structure

```
Firestore
│
├── statuses/ (Top-level collection - NEW!)
│   └── {statusId}/
│       ├── id: string
│       ├── userId: string (who created the status)
│       ├── userName: string
│       ├── userProfilePhoto: string
│       ├── mediaUrl: string (Cloudinary URL)
│       ├── mediaType: 'image' | 'video'
│       ├── caption: string (max 8 chars)
│       ├── createdAt: timestamp
│       └── expiresAt: timestamp (24 hours from creation)
│
├── users/
│   └── {userId}/
│       └── (user profile data only)
│
└── statusViews/
    └── {viewerId}/
        └── viewedStatuses/ (subcollection)
            └── {statusOwnerId}_{statusId}/
                ├── statusId: string
                ├── statusOwnerId: string
                ├── viewedAt: timestamp
                └── viewerId: string
```

### ⚠️ Important: Old vs New Structure

**OLD Structure (Before Update):**
```
users/{userId}/statuses/{statusId}  ❌ Don't use
```

**NEW Structure (After Update):**
```
statuses/{statusId}  ✅ Use this!
```

**Note:** Old statuses in the subcollection won't appear in the home feed. You need to create new statuses after this update.

---

## How It Works

### 1. **Creating a Status**
- User creates status (home or profile screen)
- Image/video uploaded to Cloudinary
- Status saved to: `statuses/{statusId}` (top-level)
- Status automatically expires after 24 hours

### 2. **Viewing Statuses in Home Screen**
- Simple query: `collection('statuses').orderBy('createdAt')`
- Fetches ALL statuses from ALL users
- Filters out expired statuses
- Groups statuses by user
- Sorts: Unseen statuses first, then by time

### 3. **Current User's Status**
- If user has status: Shows their latest status with green border
- If user has no status: Shows "Add status" card
- Can tap to view own status or add new one

### 4. **Other Users' Statuses**
- **Blue border** = User has unseen statuses
- **Grey border** = All statuses viewed
- Tap to open full-screen viewer

### 5. **Status Viewing Tracking**
- When user views a status, saves to: `statusViews/{viewerId}/viewedStatuses/`
- Persists across sessions
- Updates UI in real-time (border color changes)

---

## Firebase Rules (Security)

Add these rules to your `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profile rules
    match /users/{userId} {
      // Allow users to read any profile
      allow read: if request.auth != null;
      
      // Allow users to write only their own profile
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Status rules (top-level collection)
    match /statuses/{statusId} {
      // Anyone authenticated can read statuses (for home feed)
      allow read: if request.auth != null;
      
      // Only status owner can create/update/delete their statuses
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Status view tracking
    match /statusViews/{viewerId} {
      // Users can only read their own view history
      allow read: if request.auth != null && request.auth.uid == viewerId;
      
      match /viewedStatuses/{statusId} {
        // Users can only write their own view history
        allow create, update: if request.auth != null && request.auth.uid == viewerId;
        
        // Users can read their own view history
        allow read: if request.auth != null && request.auth.uid == viewerId;
      }
    }
  }
}
```

---

## Troubleshooting

### Problem: No statuses showing in home screen

**Solutions:**
1. **Create New Status**: Old statuses in subcollection won't appear. Create a new status after this update.
2. **Check Firebase Console**: Go to Firestore → Look for `statuses` collection (top-level, not under users)
3. **Check Console Logs**: Look for:
   ```
   📡 Querying top-level statuses collection...
   📦 Received X documents from statuses collection
   📋 Status owners: username(userId), ...
   👥 Grouped statuses from X users
   ✅ Successfully loaded X status groups
   ```
4. **Use Debug Screen**: Long press search icon on home screen to open debug screen
5. **Verify Profile**: Make sure you have completed your profile (name, username, photo)

### Problem: Can't see other users' statuses

**Solutions:**
1. Make sure other users have created statuses AFTER this update
2. Old statuses won't appear (they're in the old location)
3. Check if statuses are older than 24 hours (expired)
4. Verify Firebase rules allow reading statuses
5. Use debug screen to verify statuses exist in `statuses` collection

### Problem: Status showing but can't view it

**Solutions:**
1. Check if mediaUrl is valid in Firebase
2. Verify Cloudinary URLs are accessible
3. Check Firebase rules allow reading the status

---

## Testing Checklist

- [ ] Create status from home screen
- [ ] Create status from profile screen  
- [ ] View own status (should show green border)
- [ ] View other user's status (should show blue border)
- [ ] View status again (border should turn grey)
- [ ] Add multiple statuses (should see in status viewer)
- [ ] Wait 24 hours or manually delete - status should disappear
- [ ] Check Firebase Console - statuses should be in `statuses` collection
- [ ] Check status view tracking in `statusViews` collection

---

## Migration from Old Structure

If you had statuses in the old structure (`users/{userId}/statuses/`), they won't automatically migrate. Here's what to do:

### Option 1: Manual Migration (If you have old statuses)
Run this in your Firebase Console (Firestore → "Start Collection"):

```javascript
// This is pseudocode - you'd need to implement this as a script
// Copy statuses from users/{userId}/statuses/ to top-level statuses/
```

### Option 2: Just Create New Statuses (Recommended)
Since statuses expire after 24 hours anyway, the simplest solution is:
1. Delete old statuses (or let them expire)
2. Create new statuses
3. They'll automatically go to the new location

---

## Optional: Auto-Delete Expired Statuses (Cloud Function)

To automatically delete expired statuses from Firebase, you can add this Cloud Function:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.cleanupExpiredStatuses = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const db = admin.firestore();
    
    // Query all expired statuses from top-level collection
    const expiredQuery = await db
      .collection('statuses')
      .where('expiresAt', '<=', now)
      .get();
    
    // Delete in batches
    const batch = db.batch();
    expiredQuery.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${expiredQuery.size} expired statuses`);
    return null;
  });
```

This keeps your database clean, but it's optional since the app already filters expired statuses.

---

## Advantages of Top-Level Collection

✅ **Simpler Queries**: No collection group queries needed
✅ **No Index Required**: Standard queries work out of the box
✅ **Better Performance**: Direct collection access is faster
✅ **Industry Standard**: Used by Instagram, WhatsApp, Facebook, etc.
✅ **Easier to Query**: Can easily get all statuses or filter by userId
✅ **Simpler Rules**: Clear separation of concerns

---

## Quick Setup Steps

1. ✅ Code is already updated to use top-level collection
2. ✅ Update Firebase rules (see above)
3. ✅ Create a new status to test
4. ✅ Status will appear in `statuses` collection
5. ✅ Other users can now see your status!

That's it! No complex setup, no indexes, just works! 🎉
