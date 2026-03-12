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
        'isSold': false,
        'sellerEmail': user.email ?? '',
        'sellerDisplayName': user.displayName ?? user.email ?? '',
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

  // Update an existing product
  Future<void> updateProduct(
    String productId,
    String title,
    double price,
    String category, {
    required List<String> imageUrls,
    String description = '',
    String condition = 'Novo',
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'title': title,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'description': description,
      'condition': condition,
    });
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

  // ===== MARK AS SOLD =====

  Future<void> markAsSold(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'isSold': true,
    });
  }

  // ===== FAVORITES =====

  Future<void> addToFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFromFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  Stream<Set<String>> getFavoriteIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Stream<List<Product>> getFavoriteProducts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final productIds = snapshot.docs.map((doc) => doc.id).toList();
      if (productIds.isEmpty) return <Product>[];

      final products = <Product>[];
      // Fetch in batches of 10 (Firestore whereIn limit)
      for (var i = 0; i < productIds.length; i += 10) {
        final batch = productIds.sublist(
          i,
          i + 10 > productIds.length ? productIds.length : i + 10,
        );
        final querySnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        products.addAll(
          querySnapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)),
        );
      }
      return products;
    });
  }

  // ===== CART =====

  Future<void> addToCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Stream<Set<String>> getCartIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Stream<List<Product>> getCartProducts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final productIds = snapshot.docs.map((doc) => doc.id).toList();
      if (productIds.isEmpty) return <Product>[];

      final products = <Product>[];
      for (var i = 0; i < productIds.length; i += 10) {
        final batch = productIds.sublist(
          i,
          i + 10 > productIds.length ? productIds.length : i + 10,
        );
        final querySnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        products.addAll(
          querySnapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)),
        );
      }
      return products;
    });
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ===== PURCHASED =====

  Future<void> markAsPurchased(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Korisnik nije prijavljen");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .doc(productId)
        .set({'purchasedAt': FieldValue.serverTimestamp()});
  }

  Stream<List<Product>> getPurchasedProducts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final productIds = snapshot.docs.map((doc) => doc.id).toList();
      if (productIds.isEmpty) return <Product>[];

      final products = <Product>[];
      for (var i = 0; i < productIds.length; i += 10) {
        final batch = productIds.sublist(
          i,
          i + 10 > productIds.length ? productIds.length : i + 10,
        );
        final querySnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        products.addAll(
          querySnapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)),
        );
      }
      return products;
    });
  }

  // ===== COUNTS (for profile badges) =====

  Stream<int> getFavoritesCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> getCartCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> getPurchasedCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .snapshots()
        .map((s) => s.docs.length);
  }
}
