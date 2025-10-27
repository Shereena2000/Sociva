# 🔧 Call Feature Troubleshooting Guide

## ✅ Issue Fixed: "Calling..." Screen Stuck

### What Was the Problem?
The app was showing "Calling..." but not connecting. The error log showed:
```
I/spdlog: api name RtcEngine_setEnableSpeakerphone_5039d15 result 0 outdata {"result":-3}
I/flutter: ❌ Error joining channel: AgoraRtcException(-3, null)
```

### What Error Code -3 Means:
- **Error -3**: Invalid argument or missing required parameter
- In this case, the `CallModel` was missing `receiverName` and `receiverImage` fields

### What Was Fixed:
1. ✅ Added `receiverName` and `receiverImage` to `CallModel`
2. ✅ Updated `CallRepository.createCall()` to require receiver information
3. ✅ Updated `CallViewModel.startCall()` to pass receiver information
4. ✅ Updated `ChatAppBar` to fetch current user info from Firestore
5. ✅ Updated Call Screen UI to show the correct person's profile

---

## 🎯 How to Test the Fix

### 1. Run the App:
```bash
flutter run
```

### 2. Make a Test Call:
1. Open a chat with any user
2. Tap the **phone icon** ☎️
3. Select **"Voice Call"**
4. You should see:
   - The other person's profile picture
   - Their name
   - "Calling..." status
   - Call controls at the bottom

### 3. What to Expect:
- **Voice Call Screen**: Shows the receiver's profile with animated rings
- **Controls**: Speaker, Start Video, Mute, End Call buttons
- **Status**: Changes from "Calling..." to "Connected" when they join

---

## 🐛 Common Errors & Solutions

### Error: "Agora App ID not configured"
**Cause**: App ID not set in `agora_config.dart`

**Solution**:
```dart
// lib/Features/chat/call/config/agora_config.dart
static const String appId = '2d2918331ffb4b2e98b51d6f8e16c0c5'; // Your actual App ID
```

---

### Error: "Permissions not granted"
**Cause**: User denied microphone or camera permissions

**Solution**:
1. Go to Android Settings → Apps → Your App → Permissions
2. Enable Microphone and Camera
3. Restart the app and try again

---

### Error: "Failed to join channel" (Error -3)
**Cause**: Invalid channel parameters or missing data

**Solution**: ✅ Already fixed! The app now properly passes all required information.

---

### Error: "User not authenticated"
**Cause**: User is not logged in

**Solution**:
1. Make sure you're logged in to the app
2. Check Firebase Authentication is working
3. Restart the app if needed

---

### Error: "Cannot see remote user"
**Cause**: Other user hasn't joined the call yet

**Solution**:
- This is normal! The remote user will appear when they accept the call
- For testing, you need 2 devices or accounts

---

### Error: Video not showing (black screen)
**Cause**: Camera permission not granted or camera in use

**Solution**:
1. Check camera permissions are granted
2. Close other apps using the camera
3. Try switching camera (tap the small video preview)

---

## 📱 Testing Checklist

### Voice Call Testing:
- [ ] Can initiate voice call
- [ ] See receiver's profile picture and name
- [ ] Hear audio when connected
- [ ] Mute button works
- [ ] Speaker button works
- [ ] Can upgrade to video with "Start Video" button
- [ ] "Share Video" confirmation appears
- [ ] End call button works

### Video Call Testing:
- [ ] Can initiate video call directly
- [ ] See local video preview (small, top-right)
- [ ] See remote video (full screen) when connected
- [ ] Can switch camera (tap small preview)
- [ ] Can toggle video on/off
- [ ] Mute button works
- [ ] End call button works

---

## 🔍 Debug Logs

### What to Look For:

**Successful Connection:**
```
I/spdlog: api name RtcEngine_initialize_0320339 result 0
I/spdlog: api name RtcEngine_enableAudio result 0
I/spdlog: api name RtcEngine_joinChannel result 0
I/flutter: ✅ Local user joined channel: channel_name
I/flutter: 👤 Remote user joined: 12345
```

**Failed Connection:**
```
I/flutter: ❌ Error joining channel: AgoraRtcException(-3, null)
I/flutter: ❌ Failed to start call: Exception
```

---

## 🆘 Still Having Issues?

### Check These:

1. **Agora App ID**: Verify it's correct in `agora_config.dart`
2. **Internet Connection**: Both devices need internet
3. **Permissions**: Microphone and camera must be allowed
4. **Firestore**: Check `calls` collection is created
5. **Firebase Auth**: User must be logged in

### Enable Debug Logs:
The app already has debug logs. Check your console for:
- ✅ Success messages (green checkmarks)
- ❌ Error messages (red X marks)
- 👤 User events (person emoji)
- 📞 Call events (phone emoji)

---

## ✨ Everything Working?

If calls are working properly, you should see:
1. ✅ Call screen appears immediately
2. ✅ Correct person's profile and name shown
3. ✅ Audio/video works when connected
4. ✅ All controls (mute, speaker, video) work
5. ✅ Call ends cleanly

**Enjoy your new calling feature!** 🎉

