# 📞 Voice & Video Call Feature - Complete Setup Guide

## ✅ What's Been Implemented

I've implemented a complete voice and video calling system using Agora SDK with the following features:

### Features:
- ✅ Voice calls from chat screen
- ✅ Video calls from chat screen
- ✅ Upgrade from voice to video during call (with confirmation dialog)
- ✅ Mute/Unmute microphone
- ✅ Speaker on/off toggle
- ✅ Switch camera (front/back)
- ✅ Beautiful UI matching your app's design
- ✅ MVVM architecture with Provider
- ✅ Firestore integration for call management
- ✅ Permission handling
- ✅ Android configuration complete

---

## 🚀 Setup Steps

### Step 1: Get Your Agora App ID

1. **Go to Agora Console:**
   - Visit: https://console.agora.io/
   - Click "Sign Up" (or "Sign In" if you have an account)

2. **Create Account:**
   - Use your email or GitHub account
   - Verify your email

3. **Create a Project:**
   - Click "Project Management" in the left sidebar
   - Click "Create" button
   - Enter project name: "Social Media App Calls"
   - Choose "Secured mode: APP ID + Token" (but we'll use APP ID only for now)
   - Click "Submit"

4. **Get Your App ID:**
   - You'll see your project listed
   - Click the "eye" icon to reveal the App ID
   - Copy the App ID (it looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)

5. **Add App ID to Your Code:**
   - Open: `lib/Features/chat/call/config/agora_config.dart`
   - Replace `'YOUR_AGORA_APP_ID_HERE'` with your actual App ID:
   
   ```dart
   static const String appId = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6'; // Your actual App ID
   ```

---

### Step 2: Install Dependencies

Run this command in your terminal:

```bash
cd /Users/shereenamj/Flutter/Earning_Fish/social_media_app
flutter pub get
```

---

### Step 3: Test the Implementation

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test Voice Call:**
   - Open a chat with any user
   - Tap the phone icon in the app bar
   - Select "Voice Call"
   - You should see the voice call screen with:
     - User's profile picture with animated rings
     - Speaker, Start Video, Mute, and End Call buttons

3. **Test Video Call:**
   - From voice call, tap "Start Video"
   - Confirm the dialog
   - Video should start showing

4. **Test Upgrade to Video:**
   - Start a voice call
   - Tap "Start Video" button
   - Confirm "Share Video" dialog
   - Call upgrades to video

---

## 📱 How It Works

### User Flow:

1. **Making a Call:**
   ```
   Chat Screen → Tap Phone Icon → Choose Voice/Video → Call Screen
   ```

2. **During Voice Call:**
   - Speaker button: Toggle speaker on/off
   - Start Video button: Upgrade to video call (shows confirmation)
   - Mute button: Mute/unmute microphone
   - End Call button: End the call

3. **During Video Call:**
   - Start/Stop Video button: Toggle camera
   - Mute button: Mute/unmute microphone
   - End Call button: End the call
   - Tap small video preview: Switch camera (front/back)

---

## 🔧 Troubleshooting

### Issue: "Agora App ID not configured"
**Solution:** Make sure you added your App ID in `agora_config.dart`

### Issue: "Permissions not granted"
**Solution:** 
- Allow microphone and camera permissions when prompted
- Check Android settings if permissions were denied

### Issue: "Failed to join channel"
**Solution:**
- Check your internet connection
- Verify your Agora App ID is correct
- Make sure Agora project is active in console

### Issue: "Cannot see remote user"
**Solution:**
- Both users need to be on the call
- Check if the other user accepted the call
- Verify both users have internet connection

---

## 📊 Firestore Structure

Calls are stored in Firestore:

```
calls (collection)
  └── {channelName} (document)
      ├── callId: string
      ├── callerId: string
      ├── receiverId: string
      ├── callerName: string
      ├── callerImage: string
      ├── channelName: string
      ├── callType: 'voice' | 'video'
      ├── status: 'ringing' | 'ongoing' | 'ended'
      └── timestamp: timestamp
```

---

## 🎯 Next Steps (Optional Enhancements)

### 1. **Add Push Notifications for Incoming Calls**
   - Use Firebase Cloud Messaging
   - Send notification when call document is created
   - Show incoming call screen even when app is in background

### 2. **Add Token Server for Production**
   - More secure than using App ID only
   - Use Firebase Cloud Functions
   - Generate tokens dynamically

### 3. **Add Call History**
   - Store call records in Firestore
   - Show call duration
   - Display in chat or profile

### 4. **Add Group Calls**
   - Support multiple participants
   - Show grid view of participants

---

## 📝 Files Created/Modified

### New Files:
1. `lib/Features/chat/call/model/call_model.dart` - Call data model
2. `lib/Features/chat/call/repository/call_repository.dart` - Firestore operations
3. `lib/Features/chat/call/view_model/call_view_model.dart` - Business logic
4. `lib/Features/chat/call/config/agora_config.dart` - Agora configuration
5. `lib/Features/chat/call/view/ui.dart` - Call screen UI

### Modified Files:
1. `pubspec.yaml` - Added Agora and permission dependencies
2. `lib/Features/chat/chat_detail/view/widgets/chat_app_bar.dart` - Added call button
3. `lib/Features/chat/chat_detail/view/ui.dart` - Pass receiverId
4. `android/app/build.gradle.kts` - Set minSdk to 21
5. `android/app/src/main/AndroidManifest.xml` - Added permissions

---

## 🎨 UI Features

- **Voice Call Screen:**
  - Black background
  - Large profile picture with animated rings
  - Caller name and status
  - Control buttons at bottom

- **Video Call Screen:**
  - Full-screen remote video
  - Small local video preview (top-right)
  - Control buttons at bottom
  - Tap local preview to switch camera

- **Call Options Dialog:**
  - Clean bottom sheet
  - Voice call option (green)
  - Video call option (blue)

---

## 💡 Tips

1. **Testing with Two Devices:**
   - Install app on two phones
   - Login with different accounts
   - Start a chat
   - Make a call from one device
   - Accept on the other device

2. **Testing on Emulator:**
   - Emulators don't have cameras
   - Voice calls will work
   - Video calls won't show video

3. **Production Deployment:**
   - Enable token authentication in Agora console
   - Set up token server (Firebase Cloud Functions)
   - Update `agora_config.dart` to use tokens

---

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify your Agora App ID is correct
3. Check Firestore security rules allow call documents
4. Ensure all permissions are granted

---

## ✨ Enjoy Your New Calling Feature!

Your app now has professional voice and video calling capabilities! 🎉

