import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to handle uploading images to Cloudinary (Free Image Hosting)
/// This bypasses Firebase Storage completely!
class ImageUploadService {
  // ---------------------------------------------------------
  // TODO: Add your Cloudinary details here to enable image uploads!
  // 1. Go to https://cloudinary.com/ and create a free account.
  // 2. Find your "Cloud Name" on the dashboard and paste it below.
  // 3. Go to Settings (gear icon) -> Upload. Scroll down to "Upload presets".
  // 4. Click "Add upload preset". Set "Signing Mode" to "Unsigned".
  // 5. Copy the preset name and paste it below. Save the preset on Cloudinary.
  // ---------------------------------------------------------

  static const String cloudName = 'dpvj4h8fc';
  static const String uploadPreset = 'jskg8xnn';

  /// Uploads the image to Cloudinary and returns the secure public URL
  static Future<String?> uploadImage(String imagePath) async {
    // If user hasn't configured it yet, just return null so the app doesn't crash
    if (cloudName == 'YOUR_CLOUD_NAME' || uploadPreset == 'YOUR_UPLOAD_PRESET') {
      throw Exception('Cloudinary not configured. Please set cloudName and uploadPreset in image_upload_service.dart');
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final file = File(imagePath);

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['secure_url']; // Returns the live image URL!
      } else {
        throw Exception('Image upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to connect to image upload service: $e');
    }
  }
}
