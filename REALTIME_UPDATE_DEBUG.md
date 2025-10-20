# Real-time Update Debugging Guide

## How to Test Real-time Updates

### Step 1: Run the App with Debug Logging
```bash
flutter run --debug -d emulator-5554
```

### Step 2: Watch the Console for These Messages

When you open the home screen or feed screen, you should see:
```
📡 Fetching posts stream for Home screen (post type)...
📦 Received X posts from Firebase
🔄 Stream update detected - rebuilding home posts...
✅ Successfully loaded X posts with user data
🔔 Calling notifyListeners() to update UI
```

### Step 3: Test Like Action

1. **Tap the like button** on any post
2. **Watch the console** - you should see:
   ```
   ❤️ Toggle like for post: POST_ID (currently liked: false/true)
   ```
3. **Then you should see the stream update**:
   ```
   📦 Received X posts from Firebase
   🔄 Stream update detected - rebuilding home posts...
   ✅ Successfully loaded X posts with user data
   🔔 Calling notifyListeners() to update UI
   ```

### Step 4: Check UI Updates

After seeing the console messages, the UI should update showing:
- ✅ Like count increased/decreased
- ✅ Heart icon turns red (liked) or outline (unliked)

## Common Issues

### Issue 1: Stream updates but UI doesn't change
**Symptoms**: You see console messages but UI stays the same
**Cause**: Consumer widget not properly watching the ViewModel
**Fix**: Check that the widget uses `Consumer<HomeViewModel>` or `Consumer<FeedViewModel>`

### Issue 2: No stream updates after like
**Symptoms**: Only see the "Toggle like" message, no stream update
**Cause**: Firestore stream not properly configured
**Fix**: Check Firestore indexes are deployed

### Issue 3: UI updates only after manual refresh
**Symptoms**: Changes appear after pulling to refresh
**Cause**: `notifyListeners()` not being called
**Fix**: Check the logs show "🔔 Calling notifyListeners() to update UI"

## What the Console Should Show

### On App Start:
```
📡 Fetching posts stream for Home screen (post type)...
📦 Received 5 posts from Firebase
🔄 Stream update detected - rebuilding home posts...
✅ Successfully loaded 5 posts with user data
🔔 Calling notifyListeners() to update UI
```

### After Liking a Post:
```
❤️ Toggle like for post: abc123 (currently liked: false)
📦 Received 5 posts from Firebase
🔄 Stream update detected - rebuilding home posts...
✅ Successfully loaded 5 posts with user data
🔔 Calling notifyListeners() to update UI
```

### After Someone Else Likes:
```
📦 Received 5 posts from Firebase
🔄 Stream update detected - rebuilding home posts...
✅ Successfully loaded 5 posts with user data
🔔 Calling notifyListeners() to update UI
```

## Testing with Two Devices

1. Open the app on **Device A**
2. Open the app on **Device B**
3. Like a post on **Device A**
4. **Device B** should automatically update (you'll see the stream messages)
5. **Device A** should also update its own UI

## If Still Not Working

1. **Check Firestore Rules**: Make sure posts are readable
   ```
   firebase deploy --only firestore:rules
   ```

2. **Check Firestore Indexes**: Make sure indexes exist
   ```
   firebase deploy --only firestore:indexes
   ```

3. **Restart the App**: Sometimes hot reload isn't enough
   ```
   flutter run --debug
   ```

4. **Clear App Data**: Reset Firestore cache
   - Stop app
   - Clear data/cache
   - Restart app

