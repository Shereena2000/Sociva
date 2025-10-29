import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResumeDownloader {
  static Future<void> downloadAndOpenResume({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Downloading resume...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get app-specific directory (no permissions needed)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String safeFileName = fileName.trim().isEmpty
          ? _fileNameFromUrl(url)
          : fileName;
      if (!safeFileName.toLowerCase().endsWith('.pdf')) {
        safeFileName = safeFileName + '.pdf';
      }
      final savePath = '${directory!.path}/$safeFileName';

      final dio = Dio();
      
      print('🔍 DEBUG: Original URL: $url');
      
      Response<List<int>>? resp;
      
      // Strategy 1: Try original URL first (works if asset is publicly accessible)
      try {
        print('🔍 DEBUG: Attempt 1: Original URL');
        resp = await dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (s) => s != null && s < 500,
            headers: { 'Accept': 'application/pdf' },
          ),
        );
        print('🔍 DEBUG: Original URL - Status: ${resp.statusCode}, Size: ${resp.data?.length ?? 0}');
        if (_looksLikePdf(resp)) {
          print('✅ DEBUG: Successfully downloaded PDF from original URL');
        }
      } catch (e) {
        print('🔍 DEBUG: Original URL failed: $e');
      }
      
      // Strategy 2: Try private_download API if original fails or blocked
      if (resp == null || !_looksLikePdf(resp)) {
        try {
          final signedUrl = await _generatePrivateDownloadUrl(url);
          if (signedUrl != null) {
            print('🔍 DEBUG: Attempt 2: Private download URL');
            resp = await dio.get<List<int>>(
              signedUrl,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: true,
                validateStatus: (s) => s != null && s < 500,
                headers: { 'Accept': 'application/pdf' },
              ),
            );
            print('🔍 DEBUG: Private URL - Status: ${resp.statusCode}, Size: ${resp.data?.length ?? 0}');
            if (_looksLikePdf(resp)) {
              print('✅ DEBUG: Successfully downloaded PDF from private URL');
            }
          }
        } catch (e) {
          print('🔍 DEBUG: Private download failed: $e');
        }
      }

      // Strategy 3: If still no valid PDF, open in browser
      if (resp == null || !_looksLikePdf(resp)) {
        print('🔍 DEBUG: All download attempts failed, opening in browser');
        Navigator.pop(context);
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
        throw Exception('Unable to download or open resume. Please check your Cloudinary settings.');
      }
      // Save bytes to file
      final file = File(savePath);
      await file.writeAsBytes(resp.data!);

      Navigator.pop(context);

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to: $savePath'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  static String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'resume.pdf';
      return path.split('?').first;
    } catch (_) {
      return 'resume.pdf';
    }
  }

  static bool _looksLikePdf(Response<List<int>> response) {
    try {
      final bytes = response.data ?? const <int>[];
      if (bytes.length < 4) return false;
      // Magic number: %PDF
      return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _generatePrivateDownloadUrl(String assetUrl) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
    if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      print('🔍 DEBUG: Missing Cloudinary credentials for private download');
      return null;
    }
    try {
      final uri = Uri.parse(assetUrl);
      final segments = uri.pathSegments;
      
      // Detect resource type from URL path (image, raw, video, etc.)
      String resourceType = 'raw'; // default
      if (segments.length > 1) {
        final possibleType = segments[1];
        if (['image', 'raw', 'video', 'auto'].contains(possibleType)) {
          resourceType = possibleType;
        }
      }
      
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 2 >= segments.length) {
        print('🔍 DEBUG: Invalid Cloudinary URL format');
        return null;
      }
      // Skip 'upload' and 'v<version>', get the public_id path
      final afterUpload = segments.sublist(uploadIndex + 2);
      final last = afterUpload.last;
      final dot = last.lastIndexOf('.');
      final format = dot != -1 ? last.substring(dot + 1) : 'pdf';
      // Remove extension from public_id
      final fileNameWithoutExt = dot != -1 ? last.substring(0, dot) : last;
      afterUpload[afterUpload.length - 1] = fileNameWithoutExt;
      final publicId = afterUpload.join('/');

      // Use the detected resource type for private_download
      final endpoint = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/private_download');
      final auth = 'Basic ' + base64Encode('$apiKey:$apiSecret'.codeUnits);
      
      print('🔍 DEBUG: Requesting private download - resourceType: $resourceType, public_id: $publicId, format: $format');
      
      final dio = Dio();
      final resp = await dio.post(
        endpoint.toString(),
        data: FormData.fromMap({
          'public_id': publicId,
          'format': format,
          'attachment': true,
        }),
        options: Options(headers: { 'Authorization': auth }),
      );
      
      if (resp.statusCode == 200 && resp.data is Map && resp.data['url'] is String) {
        final downloadUrl = resp.data['url'] as String;
        print('✅ DEBUG: Generated private download URL');
        return downloadUrl;
      }
      print('🔍 DEBUG: Private download API returned status: ${resp.statusCode}, body: ${resp.data}');
      return null;
    } catch (e) {
      print('🔍 DEBUG: Private download URL generation error: $e');
      return null;
    }
  }
}
