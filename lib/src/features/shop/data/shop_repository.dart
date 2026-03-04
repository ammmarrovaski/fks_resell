import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/product.dart';
import 'cloudinary_service.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload images to Supabase Storage via ImageUploadService and return public URLs
  Future<List<String>> uploadImages(List<File> images) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    final List<String> downloadUrls = [];

    for (int i = 0; i < images.length; i++) {
      final url = await ImageUploadService.uploadImage(images[i]);
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  // Add a new product with images, description, and condition
  Future<void> addProduct(
    String title,
    double price,
    String category, {
    List<String> imageUrls = const [],
    String description = '',
    String condition = 'Novo',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Korisnik nije prijavljen");

      await _firestore.collection('products').add({
        'title': title,
        'price': price,
        'category': category,
        'userId': user.uid,
        'imageUrls': imageUrls,
        'description': description,
        'condition': condition,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete a product and its images from Supabase Storage
  Future<void> deleteProduct(String productId, List<String> imageUrls) async {
    try {
      // Delete images from Supabase Storage
      for (final url in imageUrls) {
        try {
          await ImageUploadService.deleteImage(url);
        } catch (_) {
          // Image may already be deleted, continue
        }
      }

      // Delete Firestore document
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Stream all products ordered by newest first
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream products for a specific user
  Stream<List<Product>> getProductsByUser(String userId) {
    return _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
