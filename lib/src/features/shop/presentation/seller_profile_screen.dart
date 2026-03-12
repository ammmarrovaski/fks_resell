import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/shop_repository.dart';
import '../domain/product.dart';
import 'product_detail_screen.dart';

class _Colors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF333333);
}

class SellerProfileScreen extends StatelessWidget {
  final String userId;
  final String sellerName;
  final String sellerEmail;

  const SellerProfileScreen({
    Key? key,
    required this.userId,
    required this.sellerName,
    required this.sellerEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shopRepo = ShopRepository();

    return Scaffold(
      backgroundColor: _Colors.background,
      body: StreamBuilder<List<Product>>(
        stream: shopRepo.getProductsByUser(userId),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          final activeListings = products.where((p) => !p.isSold).toList();
          final soldListings = products.where((p) => p.isSold).toList();

          return CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _Colors.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _Colors.bordo.withOpacity(0.8),
                          _Colors.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _Colors.bordo.withOpacity(0.2),
                            border: Border.all(color: _Colors.bordo, width: 2),
                          ),
                          child: const Icon(Icons.person_rounded, color: _Colors.bordo, size: 44),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sellerName.isNotEmpty ? sellerName : 'Prodavač',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _Colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BORDO PORODICA',
                          style: TextStyle(
                            fontSize: 11,
                            color: _Colors.bordo,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _statCard('${products.length}', 'Ukupno oglasa'),
                      const SizedBox(width: 12),
                      _statCard('${activeListings.length}', 'Aktivnih'),
                      const SizedBox(width: 12),
                      _statCard('${soldListings.length}', 'Prodano'),
                    ],
                  ),
                ),
              ),

              // Loading indicator
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: _Colors.bordo, strokeWidth: 2.5),
                    ),
                  ),
                ),

              // Active listings
              if (activeListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _Colors.bordo,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Aktivni oglasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _Colors.bordo.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activeListings.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _Colors.bordo,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _productCard(context, activeListings[index]),
                      childCount: activeListings.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                  ),
                ),
              ],

              // Sold listings
              if (soldListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _Colors.textMuted,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Prodano',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _Colors.textMuted.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${soldListings.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _Colors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _productCard(context, soldListings[index]),
                      childCount: soldListings.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                  ),
                ),
              ],

              // Empty state
              if (!snapshot.hasData || products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 56, color: _Colors.textMuted.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Nema aktivnih oglasa',
                          style: TextStyle(fontSize: 16, color: _Colors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Colors.divider),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _Colors.bordo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: _Colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product product) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Colors.divider.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: _Colors.surface),
                            errorWidget: (_, __, ___) => Container(
                              color: _Colors.surface,
                              child: const Icon(Icons.image_outlined, color: _Colors.textMuted),
                            ),
                          )
                        : Container(
                            color: _Colors.surface,
                            child: const Icon(Icons.shopping_bag_outlined, color: _Colors.textMuted),
                          ),
                  ),
                  if (product.isSold)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRODANO',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _Colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      '${product.price.toStringAsFixed(0)} KM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: product.isSold ? _Colors.textMuted : _Colors.bordo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}