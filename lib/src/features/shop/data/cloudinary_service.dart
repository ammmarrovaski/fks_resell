import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  // ============================================================
  // POSTAVI OVE VRIJEDNOSTI SA SVOG SUPABASE DASHBOARD-a:
  // Settings > API > Project URL  i  Project API keys (anon public)
  // ============================================================
  static const String _supabaseUrl = 'https://xwbkwdwxbemnwrdcixye.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_3IHb6yDQQszUlY1InylHQA_mYOWpQVt';
  static const String _bucketName = 'product-images';

  /// Uploads an image to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  static Future<String> uploadImage(File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = imageFile.path.split('/').last;
    final filePath = '$timestamp\_$fileName';

    // Upload via Supabase Storage REST API
    final uploadUrl = Uri.parse(
      '$_supabaseUrl/storage/v1/object/$_bucketName/$filePath',
    );

    final bytes = await imageFile.readAsBytes();

    // Determine content type
    final ext = fileName.split('.').last.toLowerCase();
    String contentType = 'image/jpeg';
    if (ext == 'png') contentType = 'image/png';
    if (ext == 'webp') contentType = 'image/webp';
    if (ext == 'gif') contentType = 'image/gif';

    final response = await http.post(
      uploadUrl,
      headers: {
        'Authorization': 'Bearer $_supabaseAnonKey',
        'apikey': _supabaseAnonKey,
        'Content-Type': contentType,
      },
      body: bytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Build the public URL
      final publicUrl =
          '$_supabaseUrl/storage/v1/object/public/$_bucketName/$filePath';
      return publicUrl;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        'Greska pri uploadu slike: ${errorBody['message'] ?? errorBody['error'] ?? response.body}',
      );
    }
  }
}
