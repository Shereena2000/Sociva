// import 'package:flutter_dotenv/flutter_dotenv.dart';

// /// Cloudinary Configuration
// /// 
// /// Credentials are stored in .env file for security
// /// Make sure to add your CLOUDINARY_CLOUD_NAME in .env file

// class CloudinaryConfig {
//   // Load from environment variables
//   static String get cloudName => 
//       dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'YOUR_CLOUD_NAME';
  
//   static String get apiKey => 
//       dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  
//   static String get apiSecret => 
//       dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  
//   static String get uploadPreset => 
//       dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'fresh-fold';
  
//   // Upload URL
//   static String get uploadUrl => 
//       'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
//   // Folder structure
//   static const String promoFolder = 'fresh_fold/promos';
  
//   // Check if configuration is valid
//   static bool get isConfigured => 
//       cloudName != 'YOUR_CLOUD_NAME' && cloudName.isNotEmpty;
// }

