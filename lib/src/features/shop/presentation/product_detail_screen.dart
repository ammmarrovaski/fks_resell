import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/shop_repository.dart';
import '../domain/product.dart';

class _DetailColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pageController = PageController();
  final _shopRepo = ShopRepository();
  int _currentPage = 0;
  bool _isDeleting = false;

  bool get _isOwner {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == widget.product.userId;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _DetailColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Obrisi artikal?',
          style: TextStyle(color: _DetailColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ova akcija se ne moze poništiti. Artikal i sve slike ce biti trajno uklonjeni.',
          style: TextStyle(color: _DetailColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani', style: TextStyle(color: _DetailColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProduct();
            },
            child: Text('Obrisi', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    setState(() => _isDeleting = true);
    try {
      await _shopRepo.deleteProduct(widget.product.id, widget.product.imageUrls);
      if (mounted) {
        Navigator.pop(context, true); // true = was deleted
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska pri brisanju: $e'),
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasImages = product.imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: _DetailColors.background,
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _DetailColors.bordo),
                  SizedBox(height: 16),
                  Text('Brisanje artikla...', style: TextStyle(color: _DetailColors.textSecondary)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Image carousel as SliverAppBar
                SliverAppBar(
                  expandedHeight: hasImages ? 360 : 200,
                  pinned: true,
                  backgroundColor: _DetailColors.cardBg,
                  leading: _buildBackButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: hasImages ? _buildImageCarousel(product) : _buildNoImagePlaceholder(product),
                  ),
                ),

                // Product details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _DetailColors.bordo,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _DetailColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category + Condition chips
                        Row(
                          children: [
                            _buildChip(product.category, Icons.tag),
                            const SizedBox(width: 10),
                            _buildChip(product.condition, Icons.verified_outlined),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        if (product.description.isNotEmpty) ...[
                          const Text(
                            'Opis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _DetailColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _DetailColors.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _DetailColors.textMuted.withOpacity(0.1)),
                            ),
                            child: Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: _DetailColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Date
                        if (product.createdAt != null)
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: _DetailColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                'Objavljeno ${_formatDate(product.createdAt!)}',
                                style: const TextStyle(fontSize: 13, color: _DetailColors.textMuted),
                              ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // Delete button for owner
                        if (_isOwner)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _confirmDelete,
                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                              label: Text(
                                'OBRISI ARTIKAL',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade400.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
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
    );
  }

  Widget _buildImageCarousel(Product product) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: product.imageUrls.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: product.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: _DetailColors.inputBg,
                child: const Center(
                  child: CircularProgressIndicator(color: _DetailColors.bordo, strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: _DetailColors.inputBg,
                child: const Icon(Icons.broken_image_rounded, color: _DetailColors.textMuted, size: 48),
              ),
            );
          },
        ),

        // Dot indicators
        if (product.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(product.imageUrls.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

        // Image counter
        Positioned(
          top: 48,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/${product.imageUrls.length}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoImagePlaceholder(Product product) {
    return Container(
      color: _DetailColors.inputBg,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 64,
          color: _DetailColors.bordo.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _DetailColors.bordo.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DetailColors.bordo.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _DetailColors.bordo),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _DetailColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'];
    return '${date.day}. ${months[date.month - 1]} ${date.year}.';
  }
}
