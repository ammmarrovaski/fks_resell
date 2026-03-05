import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';
import '../../shop/presentation/product_detail_screen.dart';

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

    // Category filter
    if (_selectedCategory != 'Sve') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Search filter
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
              child: _isSearching ? _buildSearchBar() : _buildHeader(),
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? _HomeColors.bordo : _HomeColors.cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected ? _HomeColors.bordo : _HomeColors.textMuted.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[cat] ?? Icons.category,
                            size: 16,
                            color: isSelected ? Colors.white : _HomeColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : _HomeColors.textSecondary,
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
                    return const Center(child: CircularProgressIndicator(color: _HomeColors.bordo));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: _HomeColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('Greska pri ucitavanju', style: TextStyle(color: _HomeColors.textSecondary, fontSize: 16)),
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
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(color: _HomeColors.cardBg, shape: BoxShape.circle),
                            child: const Icon(Icons.storefront_outlined, size: 40, color: _HomeColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          const Text('Nema artikala', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _HomeColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Nema rezultata za "$_searchQuery"'
                                : _selectedCategory == 'Sve'
                                    ? 'Budi prvi koji objavi artikal!'
                                    : 'Nema artikala u kategoriji $_selectedCategory',
                            style: const TextStyle(fontSize: 14, color: _HomeColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: _HomeColors.bordo.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FKS Fan Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _HomeColors.textPrimary)),
            Text('Bordo porodica', style: TextStyle(fontSize: 13, color: _HomeColors.textMuted, letterSpacing: 1.5)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleSearch,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _HomeColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _HomeColors.textMuted.withOpacity(0.15)),
            ),
            child: const Icon(Icons.search_rounded, color: _HomeColors.textSecondary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _HomeColors.inputBg,
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
              color: _HomeColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _HomeColors.textMuted.withOpacity(0.15)),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _HomeColors.textMuted.withOpacity(0.1)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: _HomeColors.inputBg,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: _HomeColors.bordo, strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: _HomeColors.inputBg,
                                child: Icon(
                                  _categoryIcons[product.category] ?? Icons.shopping_bag,
                                  size: 40,
                                  color: _HomeColors.bordo.withOpacity(0.5),
                                ),
                              ),
                            )
                          : Container(
                              color: _HomeColors.inputBg,
                              child: Center(
                                child: Icon(
                                  _categoryIcons[product.category] ?? Icons.shopping_bag,
                                  size: 40,
                                  color: _HomeColors.bordo.withOpacity(0.5),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // PRODANO overlay
                  if (product.isSold)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                                  fontSize: 14,
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
                ],
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _HomeColors.textPrimary, height: 1.3),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: product.isSold ? _HomeColors.textMuted : _HomeColors.bordo,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _HomeColors.bordo.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _HomeColors.bordoLight),
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
