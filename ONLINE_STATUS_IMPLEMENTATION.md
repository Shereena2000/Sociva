# Online/Last Seen Status Implementation

## Overview
Implemented real-time online/last seen status feature for the chat detail screen. Users can now see:
- **Online** - When the other user is currently active
- **Last seen X minutes/hours/days ago** - When the user was last active
- **Offline** - When the user has no recent activity

## What Was Implemented

### 1. UserPresenceService (`lib/Service/user_presence_service.dart`)
A singleton service that manages user online/offline status:
- **setUserOnline()** - Marks user as online in Firebase
- **setUserOffline()** - Marks user as offline and updates last seen
- **getUserPresence(userId)** - Stream to listen for user presence updates
- **getLastSeenText(timestamp)** - Formats last seen timestamp into readable text

### 2. ChatRepository Updates
Added method to listen to user presence:
- **getUserPresence(userId)** - Returns stream with `isOnline` and `lastSeen` data

### 3. ChatDetailViewModel Updates
Enhanced to track other user's online status:
- Listens to other user's presence changes in real-time
- **isOtherUserOnline** - Boolean indicating if user is online
- **otherUserLastSeen** - Timestamp of last activity
- **getStatusText()** - Returns formatted status text for display

### 4. ChatAppBar Updates
Updated to display dynamic status:
- Added **statusText** parameter
- Shows "Online" in primary color when user is active
- Shows "Last seen..." in grey when user is offline
- Proper text alignment and formatting

### 5. Main App Lifecycle Integration
Integrated presence tracking in `main.dart`:
- Automatically sets user online when app starts (if logged in)
- Tracks app lifecycle (resumed/paused)
- Sets user online when app comes to foreground
- Sets user offline when app goes to background
- Listens to auth state changes

## Firebase Setup Required

### Database Structure
The feature requires two fields in the `users` collection:

```javascript
users/{userId} {
  // Existing fields...
  isOnline: boolean,        // true when user is active
  lastSeen: Timestamp,      // last activity timestamp
}
```

### Firebase Security Rules
Add these rules to allow users to update their own presence:

```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
  
  // Allow updating presence fields
  allow update: if request.auth.uid == userId 
    && request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['isOnline', 'lastSeen']);
}
```

## How It Works

### 1. App Launch
When the app starts and user is logged in:
- UserPresenceService initializes
- User's `isOnline` is set to `true` in Firebase
- `lastSeen` timestamp is updated

### 2. App Lifecycle Changes
- **App to foreground**: User set to online
- **App to background**: User set to offline with lastSeen timestamp

### 3. Chat Screen
When user opens a chat:
- ChatDetailViewModel subscribes to other user's presence
- Real-time updates whenever other user's status changes
- ChatAppBar displays current status

### 4. Status Display Logic
- **Online**: Shows "Online" in primary color
- **< 1 minute**: Shows "Last seen just now"
- **< 1 hour**: Shows "Last seen X minutes ago"
- **< 24 hours**: Shows "Last seen X hours ago"
- **1 day**: Shows "Last seen yesterday"
- **< 7 days**: Shows "Last seen X days ago"
- **> 7 days**: Shows "Last seen DD/MM/YYYY"

## Testing

### Test Online Status
1. Login with User A on Device 1
2. Login with User B on Device 2
3. User A opens chat with User B
4. User B should show as "Online"

### Test Last Seen
1. User B closes the app or puts it in background
2. Wait a few seconds
3. User A should see "Last seen X seconds/minutes ago"

### Test Status Updates
1. User B opens the app again
2. User A should immediately see "Online" status update

## Initial Data Migration (Optional)

If you have existing users, you may want to initialize their presence fields:

```dart
// Run this once to initialize existing users
Future<void> initializeUserPresence() async {
  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();
  
  final batch = FirebaseFirestore.instance.batch();
  
  for (var doc in usersSnapshot.docs) {
    if (!doc.data().containsKey('isOnline')) {
      batch.update(doc.reference, {
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }
  
  await batch.commit();
  print('✅ Initialized presence for ${usersSnapshot.docs.length} users');
}
```

## Features

✅ Real-time presence updates
✅ Automatic status management based on app lifecycle
✅ Human-readable last seen timestamps
✅ Color-coded status (green for online, grey for offline)
✅ Handles auth state changes (login/logout)
✅ Memory-efficient with stream subscriptions cleanup
✅ Works seamlessly with existing chat functionality

## Files Modified

1. `lib/Service/user_presence_service.dart` - New file
2. `lib/Features/chat/repository/chat_repository.dart` - Added getUserPresence method
3. `lib/Features/chat/chat_detail/view_model/chat_detail_view_model.dart` - Added presence tracking
4. `lib/Features/chat/chat_detail/view/widgets/chat_app_bar.dart` - Added statusText parameter
5. `lib/Features/chat/chat_detail/view/ui.dart` - Connected status to app bar
6. `lib/main.dart` - Integrated lifecycle tracking

## Notes

- The feature uses Firebase Firestore real-time listeners for instant updates
- User presence is automatically managed - no manual intervention needed
- Status updates are lightweight and don't impact app performance
- The implementation follows clean architecture principles
- All subscriptions are properly disposed to prevent memory leaks

