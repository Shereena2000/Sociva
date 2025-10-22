# PDF URL Debug Guide

## 🔍 **Problem: Cannot Open PDF**

When you tap the PDF attachment, you see an error message: "Cannot open. Please check the URL."

## 🎯 **Debug Steps:**

### **Step 1: Check Console Logs**

After you tap the PDF, look at the console output. You should see detailed logs like:

```
🔍 LeftChatBubble - _navigateToPDFViewer called
🔍 MediaUrl value: [THE ACTUAL URL]
🔍 MediaUrl is null: false
🔍 MediaUrl is empty: false
✅ MediaUrl is valid: [URL]
🔍 Attempting to parse URL...
✅ URL parsed successfully
🔍 URI scheme: https
🔍 URI host: res.cloudinary.com
🔍 URI path: /dvcodgbkd/raw/upload/...
🔍 Checking if URL can be launched...
🔍 Can launch URL: [true/false]
```

### **Step 2: Identify the Issue**

#### **Case 1: MediaUrl is null or empty**
```
🔍 MediaUrl is null: true
OR
🔍 MediaUrl is empty: true
```
**Problem**: The resume URL was not saved properly.
**Solution**: Check the upload and message sending code.

#### **Case 2: URL cannot be parsed**
```
❌ Error opening PDF: FormatException: Invalid URI
```
**Problem**: The URL format is invalid.
**Solution**: Check what's being stored in the mediaUrl field.

#### **Case 3: canLaunchUrl returns false**
```
🔍 Can launch URL: false
❌ Cannot launch PDF URL - canLaunchUrl returned false
```
**Problem**: The device doesn't recognize the URL scheme or can't access it.
**Solution**: Check URL permissions in AndroidManifest.xml and Info.plist.

#### **Case 4: URL scheme is wrong**
```
🔍 URI scheme: [something other than https]
```
**Problem**: Cloudinary URLs should always be https.
**Solution**: Check the Cloudinary upload response.

## 🛠️ **Common Fixes:**

### **Fix 1: Ensure AndroidManifest.xml has queries**
```xml
<manifest>
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="http" />
    </intent>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>
  </queries>
</manifest>
```

### **Fix 2: Ensure Info.plist has schemes**
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>http</string>
  <string>https</string>
</array>
```

### **Fix 3: Check Cloudinary Upload**
Make sure the upload is returning a proper URL:
```dart
final responseData = json.decode(response.body);
final url = responseData['secure_url'] ?? responseData['url'] ?? '';
print('📤 Cloudinary URL: $url');
```

### **Fix 4: Check Message Storage**
Ensure the URL is being saved in the message:
```dart
final message = MessageModel(
  messageId: messageId,
  chatRoomId: chatRoomId,
  senderId: currentUser.uid,
  receiverId: companyOwnerUserId,
  content: 'I have applied...',
  messageType: MessageType.jobApplication,
  mediaUrl: resumeUrl, // ← This should be the Cloudinary URL
  timestamp: DateTime.now(),
);
```

## 📋 **Test Checklist:**

### **1. Upload Test:**
- [ ] Pick a PDF file
- [ ] Check console: "Uploading resume to Cloudinary"
- [ ] Check console: "Cloudinary upload response: 200"
- [ ] Check console: "Resume URL: https://..."
- [ ] Verify URL starts with "https://"

### **2. Message Test:**
- [ ] Check console: "Sending resume message"
- [ ] Check console: "Media URL: https://..."
- [ ] Verify message stored in Firestore
- [ ] Check Firestore: messages collection has mediaUrl field

### **3. Display Test:**
- [ ] Open chat
- [ ] See resume card
- [ ] Check console: "ChatDetailScreen: Message 0"
- [ ] Check console: "MediaUrl: https://..."
- [ ] Verify mediaUrl is not null or empty

### **4. Open Test:**
- [ ] Tap resume card
- [ ] Check console: "_navigateToPDFViewer called"
- [ ] Check console: "MediaUrl value: https://..."
- [ ] Check console: "Can launch URL: true"
- [ ] PDF should open in external app

## 🔍 **What to Send Me:**

If the issue persists, copy and paste these console logs:

1. **When uploading resume:**
   ```
   Look for lines starting with:
   📤 Uploading resume...
   📤 Cloudinary URL: ...
   ```

2. **When sending message:**
   ```
   Look for lines starting with:
   📤 ChatRepository: Sending message
   📤 ChatRepository: Media URL: ...
   ```

3. **When displaying in chat:**
   ```
   Look for lines starting with:
   🔍 ChatDetailScreen: Message 0:
      MediaUrl: ...
   ```

4. **When tapping PDF:**
   ```
   Look for lines starting with:
   🔍 LeftChatBubble - _navigateToPDFViewer called
   🔍 MediaUrl value: ...
   🔍 Can launch URL: ...
   ```

## 🎯 **Expected vs Actual:**

### **Expected Flow:**
```
1. Upload PDF → Get Cloudinary URL
   Expected: https://res.cloudinary.com/dvcodgbkd/raw/upload/.../resume.pdf
   
2. Save in message → mediaUrl field
   Expected: URL is stored in Firestore
   
3. Load in chat → mediaUrl displayed
   Expected: Resume card shows with correct URL
   
4. Tap card → Launch URL
   Expected: Opens in browser/PDF app
```

### **Check Each Step:**
```
✅ Step 1: Resume uploaded successfully
✅ Step 2: URL saved in message
✅ Step 3: Message loads with mediaUrl
❌ Step 4: Cannot launch URL ← PROBLEM HERE
```

## 💡 **Quick Tests:**

### **Test 1: Check if URL is valid**
Copy the URL from console and paste in browser. Does it open?
- YES → URL is valid, problem is with app permissions
- NO → URL is invalid, problem is with Cloudinary upload

### **Test 2: Try with a known URL**
Temporarily hardcode a test URL:
```dart
final testUrl = 'https://www.google.com';
await launchUrl(Uri.parse(testUrl), mode: LaunchMode.externalApplication);
```
- Opens → App permissions are OK, problem is with the PDF URL
- Doesn't open → App permissions issue

### **Test 3: Check Cloudinary directly**
Go to Cloudinary dashboard → Media Library
- Can you see the uploaded resume?
- Can you open it by clicking the preview?
- Copy the URL and try in browser

## 🚀 **Next Steps:**

1. **Run the app** with the new debug logging
2. **Apply for a job** with a resume
3. **Tap the resume** in chat
4. **Copy all console logs** that appear
5. **Send me the logs** so I can identify exactly where it's failing

The detailed logging will show us:
- ✅ Is the URL being stored?
- ✅ What is the exact URL value?
- ✅ Can the URL be parsed?
- ✅ Can the URL be launched?
- ✅ What error occurs (if any)?

With this information, we can pinpoint and fix the exact issue!
