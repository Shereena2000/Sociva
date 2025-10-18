# Like & Comment Feature Documentation

## ✅ Implemented Features

Instagram-style like and comment functionality has been added to your social media app!

---

## 🎯 What's New

### **Like Functionality**
- ❤️ Tap heart icon to like/unlike a post
- 👥 See total like count for each post
- 🔴 Red filled heart = You liked it
- 🤍 Outlined heart = Not liked yet
- ⚡ Real-time updates via Firebase streams

### **Comment Functionality**
- 💬 Tap comment icon to open comments screen
- ✍️ Add comments to any post
- 👁️ View all comments on a post
- ⏰ See timestamps (e.g., "2h ago", "5m ago")
- 📊 See total comment count on each post
- 💾 Comments stored in Firebase

---

## 🔥 Firebase Structure

### **Posts Collection (Updated)**

```
posts/
  {postId}/
    - postId: string
    - userId: string (post owner)
    - mediaUrl: string
    - mediaType: 'image' | 'video'
    - caption: string
    - timestamp: datetime
    - likes: [userId1, userId2, ...] ← NEW!
    - commentCount: number ← NEW!
    
    comments/ (subcollection) ← NEW!
      {commentId}/
        - commentId: string
        - postId: string
        - userId: string (commenter)
        - userName: string
        - userProfilePhoto: string
        - text: string
        - timestamp: datetime
```

### **Why This Structure?**

**Likes:**
- Stored as array of user IDs directly on the post
- Fast to check if user liked (array contains check)
- Easy to count (array length)
- Prevents duplicate likes (array union/remove)

**Comments:**
- Stored as subcollection under each post
- Scales well (can handle unlimited comments)
- Efficient queries (only load comments when needed)
- Comment count cached on post for performance

---

## 📱 User Experience

### **Liking a Post**

```
1. User taps heart icon on post
2. Icon turns red and fills in
3. Like count increases by 1
4. User ID added to likes array in Firebase
5. Real-time update reflects in UI

To unlike:
1. User taps filled heart icon
2. Icon becomes outline again
3. Like count decreases by 1
4. User ID removed from likes array
```

### **Commenting on a Post**

```
1. User taps comment icon
2. Comments screen opens
3. Shows all existing comments (oldest first)
4. User types comment at bottom
5. Taps "Post" button
6. Comment appears immediately
7. Comment count increments on post
8. Timestamp shows "Just now"
```

---

## 🎨 UI Components

### **Post Card (Home Screen)**

```dart
// Like Section
❤️ [heart icon] 25  // Shows count
💬 [comment icon] 8  // Shows count
📤 [share icon]
🔖 [save icon]

// Caption
username: Caption text here...
```

### **Comments Screen**

```
╔════════════════════════════╗
║     Comments              ║
╠════════════════════════════╣
║  👤 username               ║
║     Comment text here...   ║
║     2h ago                 ║
║                            ║
║  👤 another_user           ║
║     Another comment        ║
║     5m ago                 ║
║                            ║
╠════════════════════════════╣
║  👤 [Add a comment...]  Post║
╚════════════════════════════╝
```

---

## 🔧 Code Structure (MVVM)

### **Models**

**PostModel** - `lib/Features/post/model/post_model.dart`
```dart
class PostModel {
  final List<String> likes;      // User IDs who liked
  final int commentCount;         // Total comments
  
  bool isLikedBy(String userId)  // Check if user liked
  int get likeCount              // Get like count
}
```

**CommentModel** - `lib/Features/post/model/post_model.dart`
```dart
class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String userProfilePhoto;
  final String text;
  final DateTime timestamp;
}
```

### **Repository**

**PostRepository** - `lib/Features/post/repository/post_repository.dart`

**Like Methods:**
```dart
Future<void> likePost(String postId)
Future<void> unlikePost(String postId)
Future<void> toggleLike(String postId, bool isCurrentlyLiked)
```

**Comment Methods:**
```dart
Future<void> addComment({
  required String postId,
  required String text,
  required String userName,
  required String userProfilePhoto,
})

Stream<List<CommentModel>> getComments(String postId)
Future<void> deleteComment(String postId, String commentId)
Future<int> getCommentCount(String postId)
```

### **ViewModel**

**HomeViewModel** - `lib/Features/home/view_model/home_view_model.dart`

```dart
Future<void> toggleLike(String postId, bool isCurrentlyLiked)
Future<void> addComment({
  required String postId,
  required String text,
})
```

### **View**

**HomeScreen** - `lib/Features/home/view/ui.dart`
- Displays like/comment counts
- Handles like button interaction
- Opens comments screen

**CommentsScreen** - `lib/Features/feed/view/comments_screen.dart`
- Shows all comments for a post
- Text input for new comments
- Real-time comment stream

---

## 🚀 How It Works

### **Like Flow**

```
User Interaction (View)
        ↓
HomeViewModel.toggleLike()
        ↓
PostRepository.toggleLike()
        ↓
Firebase (Update likes array)
        ↓
Stream updates automatically
        ↓
UI rebuilds with new data
```

### **Comment Flow**

```
User types comment & taps Post (View)
        ↓
HomeViewModel.addComment()
        ↓
PostRepository.addComment()
        ↓
Firebase (Create comment + increment count)
        ↓
Comments stream updates
        ↓
UI shows new comment
```

---

## 📊 Firebase Security Rules

Add these rules to `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Posts
    match /posts/{postId} {
      // Anyone can read posts
      allow read: if request.auth != null;
      
      // Only owner can create/delete posts
      allow create, delete: if request.auth != null && 
                                request.resource.data.userId == request.auth.uid;
      
      // Anyone can update likes and commentCount
      allow update: if request.auth != null;
      
      // Comments subcollection
      match /comments/{commentId} {
        // Anyone can read comments
        allow read: if request.auth != null;
        
        // Anyone can create comments
        allow create: if request.auth != null && 
                         request.resource.data.userId == request.auth.uid;
        
        // Only commenter can delete their comments
        allow delete: if request.auth != null && 
                         resource.data.userId == request.auth.uid;
      }
    }
  }
}
```

---

## ✨ Features in Detail

### **1. Real-time Updates**

Likes and comments update in real-time using Firebase streams:
- Like a post → Everyone sees the updated count immediately
- Add a comment → Appears instantly for all viewers
- No manual refresh needed

### **2. Optimistic UI Updates**

Firebase handles updates efficiently:
- `FieldValue.arrayUnion` - Adds to likes (prevents duplicates)
- `FieldValue.arrayRemove` - Removes from likes
- `FieldValue.increment` - Updates comment count atomically

### **3. Scalability**

Design supports growth:
- Comments as subcollection (unlimited comments per post)
- Efficient queries (only load comments when screen opens)
- Cached comment count (no need to count every time)

### **4. User Experience**

Instagram-like interactions:
- Visual feedback (red heart when liked)
- Clear counts (shows exact numbers)
- Time-based timestamps ("2h ago" vs full date)
- Smooth navigation (dedicated comments screen)

---

## 🧪 Testing Checklist

### **Like Functionality**
- [ ] Like a post (heart turns red, count increases)
- [ ] Unlike a post (heart becomes outline, count decreases)
- [ ] Like count updates immediately
- [ ] Other users can see your likes
- [ ] Can't like the same post twice

### **Comment Functionality**
- [ ] Open comments screen (tap comment icon)
- [ ] View existing comments
- [ ] Add a new comment
- [ ] Comment appears immediately
- [ ] Comment count increases
- [ ] Timestamp shows correctly
- [ ] Your profile picture and username show
- [ ] Empty comments are rejected

---

## 🎓 Key Concepts

### **Why Array for Likes?**

```javascript
// Option 1: Array (Chosen)
likes: ['userId1', 'userId2']
✅ Simple
✅ Fast to query
✅ Built-in uniqueness (arrayUnion)
✅ Easy to count
```

```javascript
// Option 2: Subcollection (Not used)
posts/{postId}/likes/{userId}
❌ Extra query needed for count
❌ More complex
✅ Better for detailed like data
```

### **Why Subcollection for Comments?**

```javascript
// Option 1: Subcollection (Chosen)
posts/{postId}/comments/{commentId}
✅ Unlimited comments
✅ Load only when needed
✅ Can query/sort easily
✅ Scales well
```

```javascript
// Option 2: Array (Not used)
comments: [{...}, {...}]
❌ 1MB document size limit
❌ Must load all comments
❌ Can't query efficiently
```

---

## 📦 Dependencies Added

```yaml
timeago: ^3.7.0  # For "2h ago" timestamps
```

---

## 🔄 Migration Notes

### **For Existing Posts**

If you have existing posts without likes/commentCount:

```javascript
// Old posts will have:
likes: []            // Empty array (default)
commentCount: 0      // Zero (default)
```

The code handles both old and new posts automatically!

---

## 🎯 Next Steps (Optional Enhancements)

Consider adding:
1. **Delete Comments** - Let users delete their own comments
2. **Like Comments** - Allow liking individual comments
3. **Reply to Comments** - Nested comment threads
4. **Comment Mentions** - @username mentions
5. **Like Animations** - Heart animation when liking
6. **Who Liked** - Show list of users who liked
7. **Pin Comments** - Post owner can pin important comments
8. **Report Comments** - Flag inappropriate content

---

## 🐛 Troubleshooting

### **Issue: Likes not updating**

**Check:**
1. Firebase rules allow updating likes
2. User is authenticated
3. Internet connection active
4. Post ID is correct

### **Issue: Comments not appearing**

**Check:**
1. Comments screen receives correct postId
2. Firebase rules allow creating comments
3. Text is not empty
4. User profile is loaded
5. Check Firebase Console for comment data

### **Issue: Count mismatch**

**Reason:**
- Comment count is cached on post
- Actual comment count is in subcollection

**Fix:**
- Comment count auto-updates when adding/deleting
- If mismatch occurs, delete and recreate post

---

## 💡 Pro Tips

1. **Like Animation**: Consider adding a heart animation using `AnimatedContainer` or Lottie
2. **Comment Notifications**: Add push notifications when someone comments on your post
3. **Comment Loading**: Show loading indicator while fetching comments
4. **Empty State**: Current implementation already shows "No comments yet"
5. **Keyboard Handling**: Comment input automatically adjusts for keyboard

---

## ✅ Summary

You now have a fully functional like and comment system that:
- ✅ Follows MVVM architecture
- ✅ Uses Firebase efficiently
- ✅ Updates in real-time
- ✅ Scales well
- ✅ Provides great UX
- ✅ Matches Instagram's functionality

**Happy coding! 🚀**


