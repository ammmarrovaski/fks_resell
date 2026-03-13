import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String userId;
  final List<String> imageUrls;
  final String description;
  final String condition;
  final DateTime? createdAt;
  final bool isSold;
  final bool isDeleted;
  final String? soldToUserId;
  final String sellerEmail;
  final String sellerDisplayName;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.userId,
    this.imageUrls = const [],
    this.description = '',
    this.condition = 'Novo',
    this.createdAt,
    this.isSold = false,
    this.isDeleted = false,
    this.soldToUserId,
    this.sellerEmail = '',
    this.sellerDisplayName = '',
  });

  factory Product.fromMap(Map<String, dynamic>? map, String documentId) {
    if (map == null) {
      return Product(
        id: documentId,
        title: 'Greska',
        price: 0.0,
        category: 'Ostalo',
        userId: '',
      );
    }

    // Parse imageUrls safely from dynamic list
    List<String> parsedImageUrls = [];
    if (map['imageUrls'] != null && map['imageUrls'] is List) {
      parsedImageUrls = (map['imageUrls'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Parse createdAt from Timestamp
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null && map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    }

    return Product(
      id: documentId,
      title: map['title']?.toString() ?? 'Bez naziva',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      category: map['category']?.toString() ?? 'Ostalo',
      userId: map['userId']?.toString() ?? '',
      imageUrls: parsedImageUrls,
      description: map['description']?.toString() ?? '',
      condition: map['condition']?.toString() ?? 'Novo',
      createdAt: parsedCreatedAt,
      isSold: map['isSold'] == true,
      isDeleted: map['isDeleted'] == true,
      soldToUserId: map['soldToUserId']?.toString(),
      sellerEmail: map['sellerEmail']?.toString() ?? '',
      sellerDisplayName: map['sellerDisplayName']?.toString() ?? '',
    );
  }
}