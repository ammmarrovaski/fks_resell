import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/product.dart';
import 'cloudinary_service.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProduct(String title, double price, String category, {File? imageFile}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Korisnik nije prijavljen");

      print("[DEBUG] Dodajem produkt: $title, $price, $category");

      String? imageUrl;

      // Upload image to Supabase Storage first if provided
      if (imageFile != null) {
        print("[DEBUG] Uploading image to Supabase...");
        imageUrl = await ImageUploadService.uploadImage(imageFile);
        print("[DEBUG] Image uploaded: $imageUrl");
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
