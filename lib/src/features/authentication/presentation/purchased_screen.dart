import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';
import '../data/review_repository.dart';
import '../domain/review.dart';
import '../data/user_repository.dart';

class _PurchColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
}

class PurchasedScreen extends StatelessWidget {
  const PurchasedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shopRepo = ShopRepository();

    return Scaffold(
      backgroundColor: _PurchColors.background,
      appBar: AppBar(
        backgroundColor: _PurchColors.background,
        foregroundColor: _PurchColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Kupljeni artikli',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _PurchColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: shopRepo.getPurchasedProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _PurchColors.bordo));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: _PurchColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('Greska pri ucitavanju',
                      style: TextStyle(color: _PurchColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: _PurchColors.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        size: 40, color: _PurchColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nema kupljenih artikala',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _PurchColors.textSecondary)),
                  const SizedBox(height: 6),
                  const Text('Ovdje ce se prikazati artikli koje kupis',
                      style: TextStyle(fontSize: 14, color: _PurchColors.textMuted)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _PurchasedCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class _PurchasedCard extends StatelessWidget {
  final Product product;
  const _PurchasedCard({required this.product});

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeaveReviewSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewRepo = ReviewRepository();
    final currentUser = FirebaseAuth.instance.currentUser;
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _PurchColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _PurchColors.textMuted.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: _PurchColors.inputBg,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: _PurchColors.bordo, strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: _PurchColors.inputBg,
                              child: const Icon(Icons.broken_image,
                                  color: _PurchColors.textMuted),
                            ),
                          )
                        : Container(
                            color: _PurchColors.inputBg,
                            child: Icon(Icons.shopping_bag_outlined,
                                color: _PurchColors.bordo.withOpacity(0.4), size: 32),
                          ),
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _PurchColors.textPrimary,
                              height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)} KM',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _PurchColors.bordo),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _PurchColors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Kupljeno',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _PurchColors.green,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.sellerDisplayName.isNotEmpty
                              ? 'Prodavac: ${product.sellerDisplayName}'
                              : product.category,
                          style: const TextStyle(fontSize: 12, color: _PurchColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.check_circle_rounded,
                      color: _PurchColors.green, size: 22),
                ),
              ],
            ),

            // Dugme za dojam — provjerimo da li je već ostavio
            if (currentUser != null)
              FutureBuilder<bool>(
                future: reviewRepo.hasReviewed(product.id, currentUser.uid),
                builder: (context, snapshot) {
                  final alreadyReviewed = snapshot.data ?? false;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: _PurchColors.textMuted.withOpacity(0.1)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: alreadyReviewed
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.star_rounded,
                                    color: _PurchColors.green, size: 16),
                                SizedBox(width: 6),
                                Text('Dojam ostavljen',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: _PurchColors.green,
                                        fontWeight: FontWeight.w500)),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: OutlinedButton.icon(
                                onPressed: () => _showReviewSheet(context),
                                icon: const Icon(Icons.star_outline_rounded, size: 16),
                                label: const Text('Ostavi dojam',
                                    style: TextStyle(fontSize: 13)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _PurchColors.bordo,
                                  side: BorderSide(
                                      color: _PurchColors.bordo.withOpacity(0.4)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaveReviewSheet extends StatefulWidget {
  final Product product;
  const _LeaveReviewSheet({required this.product});

  @override
  State<_LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<_LeaveReviewSheet> {
  final _reviewRepo = ReviewRepository();
  final _userRepo = UserRepository();
  final _controller = TextEditingController();
  double _rating = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final userModel = await _userRepo.getUser(currentUser.uid);
      final reviewerName = userModel?.punoIme.isNotEmpty == true
          ? userModel!.punoIme
          : currentUser.displayName ?? currentUser.email ?? 'Korisnik';

      final review = Review(
        id: '',
        productId: widget.product.id,
        reviewerId: currentUser.uid,
        sellerId: widget.product.userId,
        reviewerName: reviewerName,
        reviewerAvatar: userModel?.profilnaSlika ?? currentUser.photoURL,
        rating: _rating,
        poruka: _controller.text.trim(),
        createdAt: DateTime.now(),
      );

      await _reviewRepo.addReview(review);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dojam uspješno ostavljen!'),
            backgroundColor: const Color(0xFF722F37),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF242424),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF666666).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Ostavi dojam',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF5F5F5))),
            const SizedBox(height: 4),
            Text(
              widget.product.title,
              style: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Zvjezdice
            const Text('Ocjena',
                style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < _rating
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF666666),
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Poruka
            const Text('Poruka (opcionalno)',
                style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA))),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFFF5F5F5)),
              decoration: InputDecoration(
                hintText: 'Napišite vaše iskustvo...',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF722F37), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF722F37),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('POŠALJI DOJAM',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}