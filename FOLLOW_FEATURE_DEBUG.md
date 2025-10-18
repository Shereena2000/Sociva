# Follow Feature Debug Guide

## 🔍 **Current Issue:**
Follow feature not working after implementing subcollection structure.

## 🚨 **Possible Causes:**

### 1. **Firestore Rules Not Updated**
- The rules in Firebase Console still use old structure
- Need to update rules to support subcollections

### 2. **Authentication Issues**
- User not properly authenticated
- Rules require authentication

### 3. **Data Structure Mismatch**
- App trying to read old structure
- Need to clear old data

## 🔧 **Step-by-Step Fix:**

### **Step 1: Update Firestore Rules (CRITICAL)**

Go to Firebase Console → Firestore Database → Rules and replace with:

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

### **Step 2: Test Authentication**

Add debug logging to check if user is authenticated:

```dart
// In ProfileViewModel, add this debug code:
Future<void> toggleFollow() async {
  print('🔍 DEBUG: Starting toggleFollow');
  print('🔍 Current user: ${FirebaseAuth.instance.currentUser?.uid}');
  print('🔍 Target user: $_viewingUserId');
  print('🔍 Is current user: $isCurrentUser');
  
  if (_viewingUserId == null || isCurrentUser) {
    print('❌ DEBUG: Cannot follow - viewingUserId: $_viewingUserId, isCurrentUser: $isCurrentUser');
    return;
  }

  _isFollowActionLoading = true;
  notifyListeners();

  try {
    if (_isFollowing) {
      print('🔍 DEBUG: Unfollowing user');
      await _followRepository.unfollowUser(_viewingUserId!);
      _isFollowing = false;
      print('✅ Unfollowed user');
    } else {
      print('🔍 DEBUG: Following user');
      await _followRepository.followUser(_viewingUserId!);
      _isFollowing = true;
      print('✅ Followed user');
    }

    // Refresh the profile to get updated follower counts
    await fetchUserProfile();
    
    _isFollowActionLoading = false;
    notifyListeners();
  } catch (e) {
    print('❌ Error toggling follow: $e');
    _isFollowActionLoading = false;
    notifyListeners();
  }
}
```

### **Step 3: Check Firebase Console**

1. Go to Firebase Console
2. Check Firestore Database
3. Look for any error messages
4. Verify rules are published

### **Step 4: Clear Old Data (If Needed)**

If you have old `follows` collection data, you may need to clear it:

1. Go to Firebase Console → Firestore Database
2. Delete the `follows` collection if it exists
3. This will force the app to use the new subcollection structure

## 🧪 **Testing Steps:**

1. **Update Firestore Rules** (Step 1)
2. **Run the app**
3. **Navigate to another user's profile**
4. **Tap Follow button**
5. **Check console logs** for debug messages
6. **Check Firebase Console** for new documents

## 📊 **Expected Database Structure After Fix:**

```
users/
├── {currentUserId}/
│   ├── following/
│   │   └── {targetUserId} → {userId: targetUserId, followedAt: timestamp}
│   └── followers/
└── {targetUserId}/
    ├── following/
    └── followers/
        └── {currentUserId} → {userId: currentUserId, followedAt: timestamp}
```

## 🚨 **Common Issues:**

### Issue 1: "Permission Denied"
**Solution**: Update Firestore rules (Step 1)

### Issue 2: "User not authenticated"
**Solution**: Check if user is logged in properly

### Issue 3: "Cannot follow yourself"
**Solution**: Make sure you're viewing another user's profile

### Issue 4: Button doesn't change
**Solution**: Check if `_isFollowing` state is updating correctly

## 🎯 **Quick Test:**

1. Add debug logging (Step 2)
2. Try to follow someone
3. Check console for error messages
4. Check Firebase Console for new documents

---

**Most likely issue: Firestore rules not updated!** 🔥

