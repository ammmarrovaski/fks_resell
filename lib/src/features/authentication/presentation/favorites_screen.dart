import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';

class _FavColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color sold = Color(0xFFE53935);
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shopRepo = ShopRepository();

    return Scaffold(
      backgroundColor: _FavColors.background,
      appBar: AppBar(
        backgroundColor: _FavColors.background,
        foregroundColor: _FavColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Omiljeni',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _FavColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: shopRepo.getFavoriteProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _FavColors.bordo),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: _FavColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'Greska pri ucitavanju',
                    style: TextStyle(color: _FavColors.textSecondary, fontSize: 16),
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
                      color: _FavColors.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 40,
                      color: _FavColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nema omiljenih',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _FavColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dodaj artikle u omiljene klikom na srce',
                    style: TextStyle(fontSize: 14, color: _FavColors.textMuted),
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
              return _buildFavoriteCard(context, products[index], shopRepo);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Product product, ShopRepository shopRepo) {
    final hasImage = product.imageUrls.isNotEmpty;

    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _FavColors.sold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.favorite_border, color: _FavColors.sold, size: 28),
      ),
      onDismissed: (_) {
        shopRepo.removeFromFavorites(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Uklonjeno iz omiljenih'),
            backgroundColor: _FavColors.cardBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _FavColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _FavColors.textMuted.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Image with optional PRODANO overlay
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      hasImage
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: _FavColors.inputBg,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: _FavColors.bordo, strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _FavColors.inputBg,
                                child: const Icon(Icons.broken_image, color: _FavColors.textMuted),
                              ),
                            )
                          : Container(
                              color: _FavColors.inputBg,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: _FavColors.bordo.withOpacity(0.4),
                                size: 32,
                              ),
                            ),
                      if (product.isSold)
                        Container(
                          color: Colors.black.withOpacity(0.55),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _FavColors.sold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRODANO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                          color: _FavColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} KM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: product.isSold ? _FavColors.textMuted : _FavColors.bordo,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _FavColors.bordo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _FavColors.bordo,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Heart icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.favorite_rounded,
                  color: _FavColors.sold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
