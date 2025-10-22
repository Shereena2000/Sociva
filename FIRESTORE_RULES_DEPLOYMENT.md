# Fix Firestore Permission Denied Error

## The Problem
The Firestore security rules for the `jobs` collection haven't been deployed yet, causing "permission denied" errors.

## ✅ Solution 1: Firebase Console (EASIEST - DO THIS)

### Steps:
1. **Open Firebase Console**: https://console.firebase.google.com
2. **Select your project**
3. **Navigate to**: Firestore Database → Rules (left sidebar)
4. **Copy the rules below** and paste into the editor
5. **Click "Publish"**

### Rules to Add:

Find this section at the bottom (before the closing `}}`):

```javascript
    // ========================================
    // JOBS COLLECTION (for job postings by verified companies)
    // ========================================
    match /jobs/{jobId} {
      // Anyone authenticated can read jobs
      allow read: if isAuthenticated();
      
      // Only authenticated users with companies can create jobs
      // (Company verification check is done in app logic)
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      
      // Only job post owner can update
      allow update: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
      
      // Only job post owner can delete
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Full Rules (If You Want to Replace Everything):

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
    // USERS COLLECTION (includes search functionality)
    // ========================================
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if isOwner(userId);
      
      match /following/{followingId} {
        allow read: if isAuthenticated();
        allow write: if isAuthenticated();
      }
      
      match /followers/{followerId} {
        allow read: if isAuthenticated();
        allow write: if isAuthenticated();
      }
    }
    
    match /user_profiles/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if isOwner(userId);
    }
    
    // ========================================
    // POSTS COLLECTION
    // ========================================
    match /posts/{postId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated();
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
      
      match /comments/{commentId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update: if isAuthenticated();
        allow delete: if isAuthenticated();
      }
    }
    
    match /comments/{commentId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated();
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
    
    // ========================================
    // STATUSES COLLECTION
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
    
    match /statusViews/{viewerId}/viewedStatuses/{statusViewId} {
      allow read: if isAuthenticated() && request.auth.uid == viewerId;
      allow create: if isAuthenticated() && request.auth.uid == viewerId;
      allow update: if isAuthenticated() && request.auth.uid == viewerId;
      allow delete: if isAuthenticated() && request.auth.uid == viewerId;
    }
    
    // ========================================
    // CHAT ROOMS COLLECTION
    // ========================================
    match /chatRooms/{chatRoomId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if isAuthenticated();
      
      match /messages/{messageId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update: if isAuthenticated();
        allow delete: if isAuthenticated();
      }
    }
    
    // ========================================
    // NOTIFICATIONS COLLECTION
    // ========================================
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && 
        request.auth.uid == resource.data.toUserId;
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.fromUserId;
      allow update: if isAuthenticated() && 
        request.auth.uid == resource.data.toUserId;
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.toUserId;
    }
    
    // ========================================
    // CALLS COLLECTION
    // ========================================
    match /calls/{callId} {
      allow read: if isAuthenticated() && 
        (request.auth.uid == resource.data.callerId || 
         request.auth.uid == resource.data.receiverId);
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.callerId;
      allow update: if isAuthenticated() && 
        (request.auth.uid == resource.data.callerId || 
         request.auth.uid == resource.data.receiverId);
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.callerId;
    }
    
    // ========================================
    // COMPANIES COLLECTION
    // ========================================
    match /companies/{companyId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated() && 
        (request.auth.uid == resource.data.userId);
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
    
    // ========================================
    // JOBS COLLECTION ⭐ NEW - ADD THIS
    // ========================================
    match /jobs/{jobId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.auth.uid == request.resource.data.userId;
      allow update: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## ✅ Solution 2: Firebase CLI (If You Prefer)

### Step 1: Initialize Firebase Project
```bash
cd /Users/shereenamj/Flutter/Earning_Fish/social_media_app
firebase login
firebase projects:list
firebase use <your-project-id>
```

### Step 2: Deploy Rules
```bash
firebase deploy --only firestore:rules
```

---

## 🧪 After Deployment - Test It

### Test Steps:
1. ✅ Open your app
2. ✅ Sign in with authenticated user
3. ✅ Make sure you have a registered company
4. ✅ Navigate to Add Job Post screen
5. ✅ Fill in all fields
6. ✅ Click "Publish Job"
7. ✅ Should work now!

### Check Firebase Console:
1. Go to Firestore Database → Data
2. Look for `jobs` collection
3. Your job post should appear there

---

## 🔍 Verify Rules Are Active

### In Firebase Console:
1. Firestore Database → Rules
2. Check the "Last published" timestamp
3. Should show current date/time
4. Rules should include the `jobs` collection section

---

## ⚠️ Common Issues

### Issue: Still getting permission denied
**Check:**
- ✅ User is signed in (Firebase Auth)
- ✅ Rules are published (check timestamp)
- ✅ The field name is `userId` (not `uid`)
- ✅ Wait 1-2 minutes after publishing rules

### Issue: "request.resource.data.userId is undefined"
**Solution:** Make sure your JobModel includes `userId` field and it's being sent to Firebase.

### Issue: Company not found
**Solution:** Register company first through company registration screen

---

## 📱 Quick Check Your Current Rules

Run this in Firebase Console → Firestore Rules:

```javascript
// Test if jobs rules exist
match /jobs/{jobId} {
  // Should see this section
  allow read: if isAuthenticated();
  allow create: if isAuthenticated() && 
    request.auth.uid == request.resource.data.userId;
}
```

If you **DON'T** see this section, the rules aren't deployed yet.

---

## ✅ Success Checklist

After deploying rules, verify:
- [ ] Rules published in Firebase Console
- [ ] Timestamp shows recent publish
- [ ] `jobs` collection rules visible
- [ ] Test app - create job post
- [ ] Job appears in Firestore Database
- [ ] No more "permission denied" errors

---

**Need help?** Let me know if you're still getting errors after deploying the rules!

