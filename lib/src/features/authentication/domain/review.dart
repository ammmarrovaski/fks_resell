class Review {
  final String id;
  final String productId;
  final String reviewerId;   // ko ostavlja dojam
  final String sellerId;     // ko prima dojam
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;       // 1-5
  final String poruka;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.reviewerId,
    required this.sellerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.poruka,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      productId: map['productId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      reviewerAvatar: map['reviewerAvatar'],
      rating: (map['rating'] ?? 0).toDouble(),
      poruka: map['poruka'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'reviewerId': reviewerId,
        'sellerId': sellerId,
        'reviewerName': reviewerName,
        'reviewerAvatar': reviewerAvatar,
        'rating': rating,
        'poruka': poruka,
        'createdAt': createdAt.toIso8601String(),
      };
}