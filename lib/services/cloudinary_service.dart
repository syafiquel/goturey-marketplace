import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'dart:io'; // Required for File, but only used on non-web platforms

class CloudinaryService {
  // Replace with your Cloudinary cloud name and unsigned upload preset
  static const String _cloudName = 'dlz5d16tq'; // Replace with your Cloudinary cloud name
  static const String _uploadPreset = 'goturey_admin_product'; // Replace with your unsigned upload preset

  static Future<String?> uploadImage(XFile imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        // For web, read bytes directly from XFile
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ));
      } else {
        // For mobile/desktop, use fromPath
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        final errorData = await response.stream.bytesToString();
        print('Cloudinary upload failed with status ${response.statusCode}: $errorData');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
