import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // Replace this with your ImgBB API key (free at https://api.imgbb.com/)
  static const String _apiKey = 'YOUR_IMGBB_API_KEY';

  /// Uploads an image to ImgBB (free, no country restrictions).
  /// Returns the URL of the uploaded image.
  static Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.imgbb.com/1/upload');

    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      url,
      body: {
        'key': _apiKey,
        'image': base64Image,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final imageUrl = jsonData['data']['url'] as String;
      return imageUrl;
    } else {
      throw Exception(
        'Greska pri uploadu slike: ${response.body}',
      );
    }
  }
}
