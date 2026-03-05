import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';

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
            return const Center(
              child: CircularProgressIndicator(color: _PurchColors.bordo),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: _PurchColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'Greska pri ucitavanju',
                    style: TextStyle(color: _PurchColors.textSecondary, fontSize: 16),
                  ),
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
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: _PurchColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nema kupljenih artikala',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _PurchColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ovdje ce se prikazati artikli koje kupis',
                    style: TextStyle(fontSize: 14, color: _PurchColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildPurchasedCard(context, products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchasedCard(BuildContext context, Product product) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _PurchColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _PurchColors.textMuted.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
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
                              child: CircularProgressIndicator(color: _PurchColors.bordo, strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: _PurchColors.inputBg,
                          child: const Icon(Icons.broken_image, color: _PurchColors.textMuted),
                        ),
                      )
                    : Container(
                        color: _PurchColors.inputBg,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: _PurchColors.bordo.withOpacity(0.4),
                          size: 32,
                        ),
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
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _PurchColors.bordo,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _PurchColors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Kupljeno',
                            style: TextStyle(
                              fontSize: 11,
                              color: _PurchColors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

            // Check icon
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.check_circle_rounded,
                color: _PurchColors.green,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
