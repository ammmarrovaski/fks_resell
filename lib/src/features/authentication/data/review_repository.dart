import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/review.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _reviews => _firestore.collection('reviews');

  Future<void> addReview(Review review) async {
    await _reviews.add(review.toMap());
    await _updateSellerRating(review.sellerId);
  }

  Future<bool> hasReviewed(String productId, String reviewerId) async {
    final query = await _reviews
        .where('productId', isEqualTo: productId)
        .where('reviewerId', isEqualTo: reviewerId)
        .get();
    return query.docs.isNotEmpty;
  }

  // Bez orderBy — sortiramo u memoriji da ne treba Firestore index
  Stream<List<Review>> getReviewsForSeller(String sellerId) {
    return _reviews
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snap) {
          final reviews = snap.docs
              .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Future<void> _updateSellerRating(String sellerId) async {
    final snap = await _reviews.where('sellerId', isEqualTo: sellerId).get();
    if (snap.docs.isEmpty) return;

    final ratings = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['rating'] as num)
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _firestore.collection('users').doc(sellerId).update({
      'avgRating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': ratings.length,
    });
  }
}