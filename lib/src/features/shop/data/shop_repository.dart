import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/product.dart'; // <-- Ne zaboravi kreirati model ako već nisi

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- KORAK 2: OBJAVLJIVANJE (ADD) ---
  Future<void> addProduct(String title, double price, String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Korisnik nije prijavljen");

      await _firestore.collection('products').add({
        'title': title,
        'price': price,
        'category': category,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(), // Važno za sortiranje
      });
      print("Uspješno poslato na Firestore!");
    } catch (e) {
      print("Greška u repozitorijumu: $e");
      rethrow;
    }
  }

  // --- KORAK 1: ČITANJE (STREAM/REALTIME) ---
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true) // Najnoviji prvi
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Koristimo model Product.fromMap da konvertujemo podatke
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}