import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';

class _CartColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color sold = Color(0xFFE53935);
  static const Color green = Color(0xFF4CAF50);
}

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shopRepo = ShopRepository();

    return Scaffold(
      backgroundColor: _CartColors.background,
      appBar: AppBar(
        backgroundColor: _CartColors.background,
        foregroundColor: _CartColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Korpa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _CartColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: shopRepo.getCartProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _CartColors.bordo),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: _CartColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'Greska pri ucitavanju',
                    style: TextStyle(color: _CartColors.textSecondary, fontSize: 16),
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
                      color: _CartColors.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 40,
                      color: _CartColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Korpa je prazna',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _CartColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dodaj artikle u korpu iz shopa',
                    style: TextStyle(fontSize: 14, color: _CartColors.textMuted),
                  ),
                ],
              ),
            );
          }

          // Calculate total price (only non-sold items)
          final availableProducts = products.where((p) => !p.isSold).toList();
          final totalPrice = availableProducts.fold<double>(0, (sum, p) => sum + p.price);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildCartCard(context, products[index], shopRepo);
                  },
                ),
              ),

              // Bottom bar with total and contact button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: _CartColors.cardBg,
                  border: Border(
                    top: BorderSide(color: _CartColors.textMuted.withOpacity(0.15)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ukupno',
                            style: TextStyle(
                              fontSize: 16,
                              color: _CartColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(0)} KM',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _CartColors.bordo,
                            ),
                          ),
                        ],
                      ),
                      if (availableProducts.length < products.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${products.length - availableProducts.length} artikal(a) je prodano',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _CartColors.sold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // Contact sellers button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: availableProducts.isEmpty
                              ? null
                              : () => _showSellersSheet(context, availableProducts),
                          icon: const Icon(Icons.email_rounded, size: 20),
                          label: const Text(
                            'KONTAKTIRAJ PRODAVCE',
                            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _CartColors.bordo,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _CartColors.inputBg,
                            disabledForegroundColor: _CartColors.textMuted,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSellersSheet(BuildContext context, List<Product> products) {
    // Group products by seller email
    final sellerMap = <String, List<Product>>{};
    for (final p in products) {
      final email = p.sellerEmail.isNotEmpty ? p.sellerEmail : 'Nepoznat';
      sellerMap.putIfAbsent(email, () => []).add(p);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _CartColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _CartColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prodavci',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _CartColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${sellerMap.length} prodavac(a) za ${products.length} artikal(a)',
              style: const TextStyle(fontSize: 13, color: _CartColors.textMuted),
            ),
            const SizedBox(height: 16),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: sellerMap.entries.map((entry) {
                  final email = entry.key;
                  final sellerProducts = entry.value;
                  final displayName = sellerProducts.first.sellerDisplayName.isNotEmpty
                      ? sellerProducts.first.sellerDisplayName
                      : 'Prodavac';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _CartColors.inputBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: _CartColors.bordo.withOpacity(0.2),
                              child: const Icon(Icons.person, color: _CartColors.bordo, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _CartColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${sellerProducts.length} artikal(a)',
                                    style: const TextStyle(fontSize: 12, color: _CartColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // List product names
                        ...sellerProducts.map((p) => Padding(
                          padding: const EdgeInsets.only(left: 46, bottom: 2),
                          child: Text(
                            '- ${p.title} (${p.price.toStringAsFixed(0)} KM)',
                            style: const TextStyle(fontSize: 12, color: _CartColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        const SizedBox(height: 10),
                        if (email != 'Nepoznat')
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final itemsList = sellerProducts
                                    .map((p) => '- ${p.title} (${p.price.toStringAsFixed(0)} KM)')
                                    .join('\n');
                                final subject = Uri.encodeComponent('Upit za artikle - FKS Fan Shop');
                                final body = Uri.encodeComponent(
                                  'Pozdrav,\n\nZainteresovan/a sam za sljedece artikle:\n\n$itemsList\n\nMolim vas za vise informacija.\n\nHvala!',
                                );
                                final mailtoUrl = Uri.parse('mailto:$email?subject=$subject&body=$body');
                                if (await canLaunchUrl(mailtoUrl)) {
                                  await launchUrl(mailtoUrl);
                                }
                              },
                              icon: const Icon(Icons.email_rounded, size: 16),
                              label: const Text(
                                'Posalji email',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _CartColors.bordo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCard(BuildContext context, Product product, ShopRepository shopRepo) {
    final hasImage = product.imageUrls.isNotEmpty;

    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _CartColors.sold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.remove_shopping_cart, color: _CartColors.sold, size: 28),
      ),
      onDismissed: (_) {
        shopRepo.removeFromCart(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Uklonjeno iz korpe'),
            backgroundColor: _CartColors.cardBg,
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
            color: _CartColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _CartColors.textMuted.withOpacity(0.1)),
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
                                color: _CartColors.inputBg,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: _CartColors.bordo, strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _CartColors.inputBg,
                                child: const Icon(Icons.broken_image, color: _CartColors.textMuted),
                              ),
                            )
                          : Container(
                              color: _CartColors.inputBg,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: _CartColors.bordo.withOpacity(0.4),
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
                                color: _CartColors.sold,
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
                          color: _CartColors.textPrimary,
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
                              color: product.isSold ? _CartColors.textMuted : _CartColors.bordo,
                              decoration: product.isSold ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _CartColors.bordo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _CartColors.bordo,
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

              // Remove icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    shopRepo.removeFromCart(product.id);
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: _CartColors.textMuted.withOpacity(0.5),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
