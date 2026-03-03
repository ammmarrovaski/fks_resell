import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/product.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads image to Firebase Storage and returns the download URL.
  /// The image is stored under 'product_images/{userId}/{timestamp}_{filename}'.
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Korisnik nije prijavljen");

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = imageFile.path.split('/').last;
      final storagePath = 'product_images/${user.uid}/${timestamp}_$fileName';

      print("[DEBUG] Uploading image to: $storagePath");

      final ref = _storage.ref().child(storagePath);

      // Upload the file
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete and get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print("[DEBUG] Image uploaded successfully: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("[DEBUG] Error uploading image: $e");
      rethrow;
    }
  }

  Future<void> addProduct(String title, double price, String category, {File? imageFile}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Korisnik nije prijavljen");

      print("[DEBUG] Dodajem produkt: $title, $price, $category");

      String? imageUrl;

      // Upload image first if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final productData = <String, dynamic>{
        'title': title,
        'price': price,
        'category': category,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Only add imageUrl if we have one
      if (imageUrl != null) {
        productData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('products').add(productData);
      print("[DEBUG] Uspjesno dodano u Firestore!");
    } catch (e) {
      print("[DEBUG] Greska pri dodavanju: $e");
      rethrow;
    }
  }

  Stream<List<Product>> getProducts() {
    print("[DEBUG] getProducts() pozvan");
    
    return _firestore
        .collection('products')
        .snapshots()
        .handleError((error) {
          print("[DEBUG] Firestore error: $error");
        })
        .map((snapshot) {
          print("[DEBUG] Primljeno ${snapshot.docs.length} dokumenata");
          
          return snapshot.docs.map((doc) {
            print("[DEBUG] Dokument: ${doc.id}");
            try {
              return Product.fromMap(doc.data(), doc.id);
            } catch (e) {
              print("[DEBUG] Greska pri parsiranju: $e");
              return Product(
                id: doc.id,
                title: 'Greska',
                price: 0.0,
                category: 'N/A',
                userId: '',
              );
            }
          }).toList();
        });
  }
}
