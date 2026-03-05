import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';

class _HomeColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color bordoDark = Color(0xFF5A2129);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color cardBgHover = Color(0xFF2C2C2C);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF333333);
  static const Color accent = Color(0xFFD4A574);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _shopRepo = ShopRepository();
  final _searchController = TextEditingController();
  String _selectedCategory = 'Sve';
  String _searchQuery = '';
  bool _isSearching = false;

  final List<String> _categories = ['Sve', 'Dresovi', 'Duksevi', 'Salovi', 'Aksesoari'];

  final Map<String, IconData> _categoryIcons = {
    'Sve': Icons.apps_rounded,
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.dry_cleaning,
    'Aksesoari': Icons.watch,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    if (_selectedCategory != 'Sve') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) => p.title.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _isSearching
                    ? _buildSearchBar(key: const ValueKey('search'))
                    : _buildHeader(key: const ValueKey('header')),
              ),
            ),

            const SizedBox(height: 20),

            // Category chips
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
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? _HomeColors.bordo : _HomeColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? _HomeColors.bordo
                              : _HomeColors.divider,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _HomeColors.bordo.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[cat] ?? Icons.category,
                            size: 16,
                            color: isSelected ? Colors.white : _HomeColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : _HomeColors.textSecondary,
                              letterSpacing: 0.2,
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

            // Products grid
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _shopRepo.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _HomeColors.bordo,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _HomeColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wifi_off_rounded, size: 28, color: _HomeColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          const Text('Greska pri ucitavanju',
                              style: TextStyle(color: _HomeColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          const Text('Provjerite internet konekciju',
                              style: TextStyle(color: _HomeColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];
                  final products = _filterProducts(allProducts);

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: _HomeColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: _HomeColors.divider),
                            ),
                            child: const Icon(Icons.storefront_outlined, size: 40, color: _HomeColors.textMuted),
                          ),
                          const SizedBox(height: 20),
                          const Text('Nema artikala',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _HomeColors.textSecondary)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Nema rezultata za "$_searchQuery"'
                                  : _selectedCategory == 'Sve'
                                      ? 'Budi prvi koji objavi artikal!'
                                      : 'Nema artikala u kategoriji $_selectedCategory',
                              style: const TextStyle(fontSize: 14, color: _HomeColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
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

  Widget _buildHeader({Key? key}) {
    return Row(
      key: key,
      children: [
        // Logo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: _HomeColors.bordo.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/hz.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.sports_soccer, size: 24, color: _HomeColors.bordo);
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FKS Fan Shop',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _HomeColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'BORDO PORODICA',
                style: TextStyle(
                  fontSize: 11,
                  color: _HomeColors.bordo,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _HomeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _HomeColors.divider),
            ),
            child: const Icon(Icons.search_rounded, color: _HomeColors.textSecondary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({Key? key}) {
    return Row(
      key: key,
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _HomeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _HomeColors.bordo.withOpacity(0.4)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: _HomeColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Pretrazi artikle...',
                hintStyle: TextStyle(color: _HomeColors.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: _HomeColors.bordo, size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _HomeColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _HomeColors.divider),
            ),
            child: const Icon(Icons.close_rounded, color: _HomeColors.textSecondary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final hasImage = product.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => _openProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: _HomeColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _HomeColors.divider.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      width: double.infinity,
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: _HomeColors.surface,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: _HomeColors.bordo, strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _HomeColors.surface,
                                child: Icon(
                                  _categoryIcons[product.category] ?? Icons.shopping_bag,
                                  size: 36,
                                  color: _HomeColors.bordo.withOpacity(0.4),
                                ),
                              ),
                            )
                          : Container(
                              color: _HomeColors.surface,
                              child: Center(
                                child: Icon(
                                  _categoryIcons[product.category] ?? Icons.shopping_bag,
                                  size: 36,
                                  color: _HomeColors.bordo.withOpacity(0.4),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // PRODANO overlay
                  if (product.isSold)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRODANO',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Condition badge
                  if (!product.isSold && product.condition == 'Novo')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NOVO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product info
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
                        color: _HomeColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: product.isSold ? _HomeColors.textMuted : _HomeColors.bordo,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _HomeColors.bordo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
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
      ),
    );
  }
}
