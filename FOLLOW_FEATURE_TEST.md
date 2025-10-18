# Follow Feature Test Guide

## 🧪 **Step-by-Step Testing:**

### **Step 1: Update Firestore Rules (CRITICAL)**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database** → **Rules**
4. **Replace ALL existing rules** with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is the owner
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // ========================================
    // USERS COLLECTION
    // ========================================
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || 
        // Allow system to update follower/following counts
        (isAuthenticated() && 
         request.resource.data.diff(resource.data).affectedKeys()
           .hasOnly(['followersCount', 'followingCount']));
      allow delete: if isOwner(userId);
      
      // ========================================
      // USER'S FOLLOWING SUBCOLLECTION
      // ========================================
      match /following/{followingId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated() && 
          request.auth.uid == userId &&
          request.auth.uid != followingId; // Can't follow yourself
        allow update: if false; // No updates allowed
        allow delete: if isAuthenticated() && request.auth.uid == userId;
      }
      
      // ========================================
      // USER'S FOLLOWERS SUBCOLLECTION
      // ========================================
      match /followers/{followerId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated() && 
          request.auth.uid == followerId &&
          request.auth.uid != userId; // Can't follow yourself
        allow update: if false; // No updates allowed
        allow delete: if isAuthenticated() && request.auth.uid == followerId;
      }
    }
    
    // ========================================
    // POSTS COLLECTION
    // ========================================
    match /posts/{postId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated() && (
        // Post owner can update their post
        request.auth.uid == resource.data.userId ||
        // Anyone can update likes (for like/unlike functionality)
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['likes', 'likeCount']) ||
        // System can update comment count
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['commentCount'])
      );
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
    
    // ========================================
    // COMMENTS COLLECTION
    // ========================================
    match /comments/{commentId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated() && (
        // Comment owner can update their comment
        request.auth.uid == resource.data.userId ||
        // System can update reply count
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['replyCount'])
      );
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
    
    // ========================================
    // STATUSES COLLECTION (24-hour stories)
    // ========================================
    match /statuses/{statusId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
    
    // ========================================
    // STATUS VIEWS COLLECTION (Track who viewed statuses)
    // ========================================
    match /statusViews/{viewerId}/viewedStatuses/{statusViewId} {
      allow read: if isAuthenticated() && request.auth.uid == viewerId;
      allow create: if isAuthenticated() && request.auth.uid == viewerId;
      allow update: if isAuthenticated() && request.auth.uid == viewerId;
      allow delete: if isAuthenticated() && request.auth.uid == viewerId;
    }
  }
}
```

5. Click **"Publish"**

### **Step 2: Test the App**

1. **Run your app**
2. **Make sure you're logged in**
3. **Navigate to another user's profile** (tap on a post's profile picture)
4. **Look for the Follow button**
5. **Tap the Follow button**
6. **Check the console logs** for debug messages

### **Step 3: Check Console Logs**

Look for these debug messages:

```
🔍 DEBUG: Starting toggleFollow
🔍 Current user: [your-user-id]
🔍 Target user: [target-user-id]
🔍 Is current user: false
🔍 Is following: false
🔍 DEBUG: Following user
🔍 FOLLOW DEBUG: Starting followUser
🔍 FOLLOW DEBUG: Current user: [your-user-id]
🔍 FOLLOW DEBUG: Target user: [target-user-id]
🔍 FOLLOW DEBUG: Creating batch operation
🔍 FOLLOW DEBUG: Committing batch operation
✅ Successfully followed user: [target-user-id]
✅ Followed user
```

### **Step 4: Check Firebase Console**

1. Go to Firebase Console → Firestore Database
2. Look for these new documents:

```
users/
├── [your-user-id]/
│   └── following/
│       └── [target-user-id] → {userId: target-user-id, followedAt: timestamp}
└── [target-user-id]/
    └── followers/
        └── [your-user-id] → {userId: your-user-id, followedAt: timestamp}
```

### **Step 5: Test Unfollow**

1. **Tap the "Following" button** (should have changed from "Follow")
2. **Check console logs** for unfollow messages
3. **Check Firebase Console** - the documents should be deleted

## 🚨 **Common Issues & Solutions:**

### Issue 1: "Permission Denied"
**Solution**: Rules not updated - repeat Step 1

### Issue 2: "User not authenticated"
**Solution**: Make sure you're logged in to the app

### Issue 3: "Cannot follow yourself"
**Solution**: Navigate to another user's profile, not your own

### Issue 4: Button doesn't appear
**Solution**: Make sure you're viewing another user's profile (not your own)

### Issue 5: Button doesn't change
**Solution**: Check if `_isFollowing` state is updating

## 📊 **Expected Results:**

### **After Following:**
- ✅ Button changes from "Follow" to "Following"
- ✅ Target user's follower count increases
- ✅ Your following count increases
- ✅ Documents created in Firebase

### **After Unfollowing:**
- ✅ Button changes from "Following" to "Follow"
- ✅ Target user's follower count decreases
- ✅ Your following count decreases
- ✅ Documents deleted from Firebase

## 🎯 **Quick Fix Checklist:**

- [ ] Updated Firestore rules (Step 1)
- [ ] User is logged in
- [ ] Viewing another user's profile
- [ ] Follow button is visible
- [ ] Console logs show debug messages
- [ ] Firebase documents are created/deleted

## 🔥 **Most Likely Issue:**

**Firestore rules not updated!** This is the #1 cause of follow feature not working.

---

**Follow these steps exactly and the feature will work!** 🎉

