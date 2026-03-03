import 'package:flutter/material.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';

// Bordo boje za FK Sarajevo temu
class _HomeColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _shopRepo = ShopRepository();
  String _selectedCategory = 'Sve';

  final List<String> _categories = ['Sve', 'Dresovi', 'Duksevi', 'Salovi', 'Aksesoari'];

  final Map<String, IconData> _categoryIcons = {
    'Sve': Icons.apps_rounded,
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.dry_cleaning,
    'Aksesoari': Icons.watch,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: _HomeColors.bordo.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/hz.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.sports_soccer,
                            size: 24,
                            color: _HomeColors.bordo,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FKS Fan Shop',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _HomeColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Bordo porodica',
                        style: TextStyle(
                          fontSize: 13,
                          color: _HomeColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _HomeColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _HomeColors.textMuted.withOpacity(0.15),
                      ),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: _HomeColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category filter chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _HomeColors.bordo
                            : _HomeColors.cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? _HomeColors.bordo
                              : _HomeColors.textMuted.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[cat] ?? Icons.category,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : _HomeColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : _HomeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Products list
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _shopRepo.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _HomeColors.bordo,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: _HomeColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Greska pri ucitavanju',
                            style: TextStyle(
                              color: _HomeColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];
                  final products = _selectedCategory == 'Sve'
                      ? allProducts
                      : allProducts
                          .where((p) => p.category == _selectedCategory)
                          .toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _HomeColors.cardBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_outlined,
                              size: 40,
                              color: _HomeColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nema artikala',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _HomeColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedCategory == 'Sve'
                                ? 'Budi prvi koji objavi artikal!'
                                : 'Nema artikala u kategoriji $_selectedCategory',
                            style: const TextStyle(
                              fontSize: 14,
                              color: _HomeColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: _HomeColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _HomeColors.textMuted.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _HomeColors.inputBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: _HomeColors.bordo.withOpacity(0.5),
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              _categoryIcons[product.category] ?? Icons.shopping_bag,
                              size: 40,
                              color: _HomeColors.bordo.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        _categoryIcons[product.category] ?? Icons.shopping_bag,
                        size: 40,
                        color: _HomeColors.bordo.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _HomeColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} KM',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _HomeColors.bordo,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _HomeColors.bordo.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _HomeColors.bordoLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
