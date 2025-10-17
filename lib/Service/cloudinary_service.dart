import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  String get apiKey => dotenv.env['CLOUDINARY_API_KEY']!;
  String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  Future<void> initialize() async {
    // Cloudinary initialization is handled by environment variables
  }

  Future<String> uploadMedia(File mediaFile, {required bool isVideo}) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'social_media_posts';
      
      if (isVideo) {
        request.fields['resource_type'] = 'video';
      } else {
        request.fields['resource_type'] = 'image';
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        mediaFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] ?? responseData['url'] ?? '';
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  // Upload image specifically for profile pictures
  Future<String> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'profile_pictures';
      request.fields['resource_type'] = 'image';

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] ?? responseData['url'] ?? '';
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
