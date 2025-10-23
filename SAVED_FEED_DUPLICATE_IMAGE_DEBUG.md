# Saved Feed Duplicate Image Debug Guide

## Issue
When viewing a saved feed with 2 photos in the saved feed screen, swiping through the photos shows the same photo twice instead of showing two different photos.

## Changes Made

### 1. Fixed Permission Denied Error ✅
**File:** `lib/Features/menu/saved_feed/repository/saved_feed_repository.dart`

**Problem:** The repository was trying to access a `feeds` collection that doesn't exist in Firestore rules.

**Fix:** Changed line 61 from:
```dart
final feedDoc = await _firestore.collection('feeds').doc(savedFeed.feedId).get();
```

To:
```dart
final feedDoc = await _firestore.collection('posts').doc(savedFeed.feedId).get();
```

### 2. Added Debug Logging 🔍
Added comprehensive debug logging to help identify why the same photo appears twice.

**Files modified:**
- `lib/Features/menu/saved_feed/repository/saved_feed_repository.dart` (lines 65-76)
- `lib/Features/post/view/post_detail_screen.dart` (lines 118-124)

## How to Debug

### Step 1: Test the Saved Feed Feature
1. Run your app
2. Navigate to the saved feed screen (Menu > Saved Feeds)
3. Tap on a saved feed that has 2 photos

### Step 2: Check Debug Logs
When you open the saved feed and then tap to view details, you'll see debug output in the console like this:

```
🔍 Saved Feed Data Debug:
   Feed ID: abc123...
   Raw mediaUrls from Firestore: [url1, url2]  // <-- Check if both URLs are different
   Raw mediaUrl from Firestore: url1
   Parsed mediaUrls count: 2
   Parsed media 0: https://...image1.jpg
   Parsed media 1: https://...image2.jpg

🖼️ PostDetailScreen Media Debug:
   Post ID: abc123...
   Media count: 2
   Media 0: https://...image1.jpg  // <-- Check if this is different from Media 1
   Media 1: https://...image2.jpg
```

### Step 3: Analyze the Logs

**If both URLs are THE SAME:**
- The problem is in how the post was originally created
- The `mediaUrls` array in Firestore has duplicate URLs
- **Solution:** The issue is in the post creation flow - need to fix how files are uploaded

**If URLs are DIFFERENT:**
- The problem is in how the PostDetailScreen displays them
- **Solution:** Check the PageView implementation in PostDetailScreen

## Firestore Rules

Your `savedFeeds` collection rules are correct:

```javascript
match /savedFeeds/{savedFeedId} {
  allow read: if isAuthenticated();
  allow create: if isAuthenticated() && 
    request.resource.data.userId == request.auth.uid;
  allow delete: if isAuthenticated() && 
    resource.data.userId == request.auth.uid;
}
```

## Next Steps

1. **Run the app** and check the debug logs
2. **Share the debug output** if you need further help
3. **Check Firestore directly** - Go to Firebase Console > Firestore Database > posts collection > find your post document and check the `mediaUrls` field

## Possible Root Causes

1. **Duplicate file selection:** User accidentally selected the same image twice
2. **Upload bug:** The file upload logic uploaded the same file twice
3. **Array construction bug:** The mediaUrls array was built incorrectly
4. **PageView bug:** The PageView is displaying the same index twice

## Quick Fix (If URLs are duplicated in Firestore)

If the problem is in the Firestore data itself, you can manually fix it:

1. Go to Firebase Console
2. Find the problematic post document
3. Edit the `mediaUrls` field to ensure it has unique URLs
4. Save and test again

## Firebase Rules Deployment

To deploy your Firestore rules:
```bash
firebase use --add
# Select your project
firebase deploy --only firestore:rules
```


