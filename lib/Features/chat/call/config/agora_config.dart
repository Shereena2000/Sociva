/// Agora Configuration
/// 
/// To get your App ID:
/// 1. Go to https://console.agora.io/
/// 2. Sign up/Login
/// 3. Create a new project
/// 4. Copy the App ID and paste it below
/// 
/// IMPORTANT: Replace 'YOUR_AGORA_APP_ID_HERE' with your actual Agora App ID
class AgoraConfig {
  // TODO: Replace with your actual Agora App ID
  static const String appId = '2d2918331ffb4b2e98b51d6f8e16c0c5';
  
  // For production, you should use a token server
  // For development/testing, you can use null
  static const String? token = null;
  
  // Validate if App ID is configured
  static bool get isConfigured => appId != 'YOUR_AGORA_APP_ID_HERE' && appId.isNotEmpty;
}

