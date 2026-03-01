class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String userId;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.userId,
  });

  factory Product.fromMap(Map<String, dynamic>? map, String documentId) {
    // Ako je dokument prazan iz nekog razloga, vrati defaultne vrijednosti
    if (map == null) {
      return Product(id: documentId, title: 'Greška', price: 0.0, category: 'Ostalo', userId: '');
    }

    return Product(
      id: documentId,
      // Koristimo .toString() i tryParse da spriječimo pucanje aplikacije ako tip podataka nije tačan
      title: map['title']?.toString() ?? 'Bez naziva',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      category: map['category']?.toString() ?? 'Ostalo',
      userId: map['userId']?.toString() ?? '',
    );
  }
}