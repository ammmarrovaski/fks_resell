import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/shop_repository.dart';
import '../domain/product.dart';
import 'product_detail_screen.dart';
import '../../authentication/data/user_repository.dart';
import '../../authentication/domain/user_model.dart';
import '../../authentication/data/review_repository.dart';
import '../../authentication/domain/review.dart';

class _Colors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF333333);
}

class SellerProfileScreen extends StatefulWidget {
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
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _shopRepo = ShopRepository();
  final _userRepo = UserRepository();
  final _reviewRepo = ReviewRepository();

  List<Product> _products = [];
  UserModel? _userModel;
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('=== SELLER PROFILE: loading data for userId: \${widget.userId}');

    _shopRepo.getProductsByUser(widget.userId).listen((products) {
      print('=== PRODUCTS loaded: \${products.length}');
      if (mounted) setState(() => _products = products);
    }, onError: (e) => print('=== PRODUCTS ERROR: \$e'));

    _userRepo.watchUser(widget.userId).listen((user) {
      print('=== USER loaded: \${user?.ime}');
      if (mounted) setState(() => _userModel = user);
    }, onError: (e) => print('=== USER ERROR: \$e'));

    _reviewRepo.getReviewsForSeller(widget.userId).listen((reviews) {
      print('=== REVIEWS loaded: \${reviews.length}');
      if (mounted) setState(() {
        _reviews = reviews;
        _loading = false;
      });
    }, onError: (e) {
      print('=== REVIEWS ERROR: \$e');
      if (mounted) setState(() => _loading = false);
    });

    Future.delayed(const Duration(seconds: 3), () {
      print('=== FALLBACK: forcing _loading = false');
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeListings = _products.where((p) => !p.isSold).toList();
    final soldListings = _products.where((p) => p.isSold).toList();

    return Scaffold(
      backgroundColor: _Colors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
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
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _Colors.bordo.withOpacity(0.2),
                        border: Border.all(color: _Colors.bordo, width: 2),
                        image: _userModel?.profilnaSlika != null
                            ? DecorationImage(
                                image:
                                    NetworkImage(_userModel!.profilnaSlika!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _userModel?.profilnaSlika == null
                          ? const Icon(Icons.person_rounded,
                              color: _Colors.bordo, size: 44)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.sellerName.isNotEmpty
                          ? widget.sellerName
                          : 'Prodavač',
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
                    if (_userModel != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFD4A574), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _userModel!.avgRating > 0
                                ? _userModel!.avgRating.toStringAsFixed(1)
                                : 'Nema ocjena',
                            style: const TextStyle(
                                color: _Colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                          if (_userModel!.reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text('(${_userModel!.reviewCount})',
                                style: const TextStyle(
                                    color: _Colors.textMuted, fontSize: 12)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Na platformi od ${_userModel!.createdAt.day}.${_userModel!.createdAt.month}.${_userModel!.createdAt.year}',
                        style: const TextStyle(
                            color: _Colors.textMuted, fontSize: 12),
                      ),
                    ],
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
                  _statCard('${_products.length}', 'Ukupno oglasa'),
                  const SizedBox(width: 12),
                  _statCard('${activeListings.length}', 'Aktivnih'),
                  const SizedBox(width: 12),
                  _statCard('${soldListings.length}', 'Prodano'),
                ],
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
                    const Text('Aktivni oglasi',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Colors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _Colors.bordo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${activeListings.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _Colors.bordo,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _productCard(context, activeListings[index]),
                  childCount: activeListings.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                    const Text('Prodano',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Colors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _Colors.textMuted.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${soldListings.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _Colors.textMuted,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _productCard(context, soldListings[index]),
                  childCount: soldListings.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
              ),
            ),
          ],

          // Empty state
          if (_products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 56,
                        color: _Colors.textMuted.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text('Nema aktivnih oglasa',
                        style: TextStyle(
                            fontSize: 16,
                            color: _Colors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

          // Dojmovi header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Dojmovi',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _Colors.textPrimary)),
                  const SizedBox(width: 8),
                  if (_reviews.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_reviews.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD4A574),
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ),

          // Dojmovi lista
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: _Colors.bordo, strokeWidth: 2),
                    ),
                  )
                : _reviews.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _Colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _Colors.divider),
                          ),
                          child: const Center(
                            child: Text('Još nema dojmova',
                                style: TextStyle(
                                    color: _Colors.textMuted, fontSize: 14)),
                          ),
                        ),
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _reviews
                              .map((r) => _buildReviewCard(r))
                              .toList(),
                        ),
                      ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _Colors.cardBg,
                  image: review.reviewerAvatar != null
                      ? DecorationImage(
                          image: NetworkImage(review.reviewerAvatar!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: review.reviewerAvatar == null
                    ? const Icon(Icons.person_rounded,
                        color: _Colors.textMuted, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName.isNotEmpty
                          ? review.reviewerName
                          : 'Korisnik',
                      style: const TextStyle(
                          color: _Colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    Text(
                      '${review.createdAt.day}.${review.createdAt.month}.${review.createdAt.year}',
                      style: const TextStyle(
                          color: _Colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFD4A574),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          if (review.poruka.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.poruka,
                style: const TextStyle(
                    color: _Colors.textSecondary,
                    fontSize: 13,
                    height: 1.5)),
          ],
        ],
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
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Colors.bordo)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: _Colors.textMuted,
                    fontWeight: FontWeight.w500)),
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
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)),
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
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: _Colors.surface),
                            errorWidget: (_, __, ___) => Container(
                              color: _Colors.surface,
                              child: const Icon(Icons.image_outlined,
                                  color: _Colors.textMuted),
                            ),
                          )
                        : Container(
                            color: _Colors.surface,
                            child: const Icon(Icons.shopping_bag_outlined,
                                color: _Colors.textMuted),
                          ),
                  ),
                  if (product.isSold)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('PRODANO',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.5)),
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
                          height: 1.3),
                    ),
                    Text(
                      '${product.price.toStringAsFixed(0)} KM',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: product.isSold
                              ? _Colors.textMuted
                              : _Colors.bordo),
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