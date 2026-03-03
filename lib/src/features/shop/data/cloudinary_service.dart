import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace these with your Cloudinary credentials
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  /// Uploads an image to Cloudinary using unsigned upload.
  /// Returns the secure URL of the uploaded image.
  static Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'fks_products'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final imageUrl = jsonData['secure_url'] as String;
      return imageUrl;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        'Greska pri uploadu slike: ${errorBody['error']?['message'] ?? response.body}',
      );
    }
  }
}
