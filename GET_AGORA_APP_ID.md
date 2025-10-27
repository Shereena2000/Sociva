# 🎯 How to Get Your Agora App ID (Step-by-Step)

## Step 1: Create Agora Account

1. **Open your browser** and go to: **https://console.agora.io/**

2. **Click "Sign Up"** (top right corner)

3. **Choose sign-up method:**
   - Email (recommended)
   - GitHub account
   - Google account

4. **Fill in your details:**
   - Email address
   - Password
   - First name
   - Last name
   - Company name (you can put "Personal" or your app name)
   - Country

5. **Verify your email:**
   - Check your inbox
   - Click the verification link
   - You'll be redirected to Agora Console

---

## Step 2: Create a Project

1. **You'll see the Agora Console dashboard**

2. **Click "Project Management"** in the left sidebar

3. **Click the blue "Create" button**

4. **Fill in project details:**
   - **Project Name:** `Social Media App Calls` (or any name you like)
   - **Use Case:** Select "Social" or "Communication"
   - **Authentication mechanism:** Choose "Secured mode: APP ID + Token"
     - Don't worry! We'll use APP ID only for now (simpler)
     - You can add tokens later for production

5. **Click "Submit"**

---

## Step 3: Get Your App ID

1. **You'll see your project in the list**

2. **Find the "App ID" column**
   - It will show something like: `a1b2c3d4...` (partially hidden)

3. **Click the "eye" icon** 👁️ next to the App ID
   - This reveals the full App ID

4. **Click the "copy" icon** 📋 to copy the App ID
   - Or manually select and copy it

5. **Your App ID looks like this:**
   ```
   a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
   ```
   (32 characters, mix of letters and numbers)

---

## Step 4: Add App ID to Your Code

1. **Open this file in your code editor:**
   ```
   lib/Features/chat/call/config/agora_config.dart
   ```

2. **Find this line:**
   ```dart
   static const String appId = 'YOUR_AGORA_APP_ID_HERE';
   ```

3. **Replace `YOUR_AGORA_APP_ID_HERE` with your actual App ID:**
   ```dart
   static const String appId = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
   ```
   (Use your actual App ID, not this example)

4. **Save the file** (Cmd+S or Ctrl+S)

---

## Step 5: Verify It Works

1. **Run your app:**
   ```bash
   flutter run
   ```

2. **Open a chat with any user**

3. **Tap the phone icon** in the app bar

4. **Select "Voice Call"**

5. **If you see the call screen** → Success! ✅
   - If you see "Agora App ID not configured" → Check step 4 again

---

## 🎁 Free Tier Benefits

Agora gives you **10,000 free minutes per month**!

That's enough for:
- 333 hours of calls per month
- OR 11 hours per day
- OR plenty for testing and small apps

Perfect for development and testing! 🎉

---

## 📸 Visual Guide

### What the Agora Console Looks Like:

```
┌─────────────────────────────────────────────────┐
│  Agora Console                                  │
├─────────────────────────────────────────────────┤
│  📁 Project Management                          │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ Project Name: Social Media App Calls    │   │
│  │ App ID: a1b2c3d4... 👁️ 📋              │   │
│  │ Status: ● Active                        │   │
│  │ [Edit] [Config] [Usage]                 │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## ❓ Common Questions

### Q: Do I need a credit card?
**A:** No! The free tier doesn't require a credit card.

### Q: Will I be charged?
**A:** No, as long as you stay under 10,000 minutes/month. You'll get warnings before any charges.

### Q: Can I use one App ID for multiple apps?
**A:** Yes, but it's better to create separate projects for different apps for better tracking.

### Q: What if I lose my App ID?
**A:** Just log back into Agora Console → Project Management → Click the eye icon again.

### Q: Do I need to enable anything else?
**A:** No! Just the App ID is enough for basic calls. Tokens are optional for now.

---

## 🚨 Important Security Note

**DO NOT share your App ID publicly!**
- Don't commit it to public GitHub repos
- Don't post it in forums or chat
- Keep it in your code only

For production apps, you should use token authentication (we can add this later).

---

## ✅ Checklist

- [ ] Created Agora account
- [ ] Verified email
- [ ] Created project in Agora Console
- [ ] Copied App ID
- [ ] Pasted App ID in `agora_config.dart`
- [ ] Saved the file
- [ ] Ran `flutter run`
- [ ] Tested a call

---

## 🎉 You're Done!

Once you have your App ID configured, your calling feature is ready to use!

**Next:** Read `CALL_FEATURE_SETUP_GUIDE.md` for testing instructions.

