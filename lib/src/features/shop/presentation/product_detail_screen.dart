import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/shop_repository.dart';
import '../domain/product.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../notifications/data/notification_repository.dart';

class _DetailColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF333333);
  static const Color sold = Color(0xFFE53935);
  static const Color green = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFD4A574);
  static const Color blue = Color(0xFF42A5F5);
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
  final _chatRepo = ChatRepository();
  final _notiRepo = NotificationRepository();
  int _currentPage = 0;
  bool _isDeleting = false;
  bool _isFavorite = false;
  bool _isInCart = false;
  bool _isSold = false;
  bool _isMarkingSold = false;

  bool get _isOwner {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == widget.product.userId;
  }

  @override
  void initState() {
    super.initState();
    _isSold = widget.product.isSold;
    _listenToFavorites();
    _listenToCart();
  }

  void _listenToFavorites() {
    _shopRepo.getFavoriteIds().listen((ids) {
      if (mounted) {
        setState(() => _isFavorite = ids.contains(widget.product.id));
      }
    });
  }

  void _listenToCart() {
    _shopRepo.getCartIds().listen((ids) {
      if (mounted) {
        setState(() => _isInCart = ids.contains(widget.product.id));
      }
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _shopRepo.removeFromFavorites(widget.product.id);
      } else {
        await _shopRepo.addToFavorites(widget.product.id);
        // Send notification to product owner
        if (!_isOwner) {
          await _notiRepo.createNotification(
            toUserId: widget.product.userId,
            type: 'favorite',
            title: 'Neko je lajkovao vas artikal',
            body: '${widget.product.title} je dodan u omiljene.',
            productId: widget.product.id,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greska: $e'), backgroundColor: _DetailColors.sold),
        );
      }
    }
  }

  Future<void> _toggleCart() async {
    try {
      if (_isInCart) {
        await _shopRepo.removeFromCart(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Uklonjeno iz korpe'),
              backgroundColor: _DetailColors.cardBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        await _shopRepo.addToCart(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dodano u korpu'),
              backgroundColor: _DetailColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greska: $e'), backgroundColor: _DetailColors.sold),
        );
      }
    }
  }

  Future<void> _openChat() async {
    try {
      final chatRoomId = await _chatRepo.getOrCreateChatRoom(
        otherUserId: widget.product.userId,
        otherUserName: widget.product.sellerDisplayName.isNotEmpty
            ? widget.product.sellerDisplayName
            : 'Prodavac',
        productId: widget.product.id,
        productTitle: widget.product.title,
        productImageUrl: widget.product.imageUrls.isNotEmpty
            ? widget.product.imageUrls.first
            : null,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatRoomId: chatRoomId,
              otherUserName: widget.product.sellerDisplayName.isNotEmpty
                  ? widget.product.sellerDisplayName
                  : 'Prodavac',
              productTitle: widget.product.title,
              productImageUrl: widget.product.imageUrls.isNotEmpty
                  ? widget.product.imageUrls.first
                  : null,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greska: $e'), backgroundColor: _DetailColors.sold),
        );
      }
    }
  }

  void _showContactSheet() {
    final product = widget.product;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _DetailColors.cardBg,
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
                  color: _DetailColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Kontaktiraj prodavca',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _DetailColors.textPrimary),
            ),
            const SizedBox(height: 20),

            // Seller info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _DetailColors.inputBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _DetailColors.bordo.withOpacity(0.2),
                    child: const Icon(Icons.person, color: _DetailColors.bordo, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.sellerDisplayName.isNotEmpty ? product.sellerDisplayName : 'Prodavac',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _DetailColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.sellerEmail.isNotEmpty ? product.sellerEmail : 'Email nije dostupan',
                          style: const TextStyle(fontSize: 13, color: _DetailColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Send message button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openChat();
                },
                icon: const Icon(Icons.chat_rounded, size: 20),
                label: const Text(
                  'POSALJI PORUKU',
                  style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DetailColors.bordo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Copy email button
            if (product.sellerEmail.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: product.sellerEmail));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Email kopiran u clipboard'),
                        backgroundColor: _DetailColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: _DetailColors.textSecondary, size: 18),
                  label: const Text(
                    'Kopiraj email',
                    style: TextStyle(color: _DetailColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _DetailColors.textMuted.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _confirmMarkAsSold() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _DetailColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Oznaci kao prodano?',
            style: TextStyle(color: _DetailColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Artikal ce biti oznacen kao prodan i kupci ga vise nece moci kupiti.',
            style: TextStyle(color: _DetailColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Odustani', style: TextStyle(color: _DetailColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _markAsSold();
            },
            child: const Text('Oznaci', style: TextStyle(color: _DetailColors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsSold() async {
    setState(() => _isMarkingSold = true);
    try {
      await _shopRepo.markAsSold(widget.product.id);
      if (mounted) {
        setState(() {
          _isSold = true;
          _isMarkingSold = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Artikal oznacen kao prodan'),
            backgroundColor: _DetailColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMarkingSold = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greska: $e'), backgroundColor: _DetailColors.sold),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _DetailColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Obrisi artikal?',
            style: TextStyle(color: _DetailColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Ova akcija se ne moze ponistiti. Artikal i sve slike ce biti trajno uklonjeni.',
            style: TextStyle(color: _DetailColors.textSecondary, fontSize: 14)),
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
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska pri brisanju: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  expandedHeight: hasImages ? 380 : 200,
                  pinned: true,
                  backgroundColor: _DetailColors.surface,
                  leading: _buildBackButton(),
                  actions: [
                    if (!_isOwner)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isFavorite ? _DetailColors.sold.withOpacity(0.5) : Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: _isFavorite ? _DetailColors.sold : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        hasImages
                            ? _buildImageCarousel(product)
                            : _buildNoImagePlaceholder(product),
                        if (_isSold)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _DetailColors.sold,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _DetailColors.sold.withOpacity(0.4),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'PRODANO',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Product details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PRODANO badge inline
                        if (_isSold)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _DetailColors.sold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _DetailColors.sold.withOpacity(0.25)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: _DetailColors.sold, size: 16),
                                SizedBox(width: 6),
                                Text('Ovaj artikal je prodan',
                                    style: TextStyle(color: _DetailColors.sold, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),

                        // Price
                        Text(
                          '${product.price.toStringAsFixed(0)} KM',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _isSold ? _DetailColors.textMuted : _DetailColors.bordo,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

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
                          const Text('Opis',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _DetailColors.textPrimary)),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _DetailColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _DetailColors.divider),
                            ),
                            child: Text(
                              product.description,
                              style: const TextStyle(fontSize: 15, color: _DetailColors.textSecondary, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Seller info section
                        if (!_isOwner && product.sellerDisplayName.isNotEmpty) ...[
                          const Text('Prodavac',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _DetailColors.textPrimary)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _DetailColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _DetailColors.divider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _DetailColors.bordo.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: _DetailColors.bordo, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.sellerDisplayName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _DetailColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Clan bordo porodice',
                                        style: TextStyle(fontSize: 12, color: _DetailColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chat shortcut
                                if (!_isSold)
                                  GestureDetector(
                                    onTap: _openChat,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _DetailColors.bordo.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.chat_rounded, color: _DetailColors.bordo, size: 18),
                                    ),
                                  ),
                              ],
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

                        // === BUYER ACTIONS ===
                        if (!_isOwner && !_isSold) ...[
                          // Send message button (PRIMARY)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _openChat,
                              icon: const Icon(Icons.chat_rounded, size: 20),
                              label: const Text(
                                'POSALJI PORUKU',
                                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _DetailColors.bordo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Contact via email + Cart row
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: _showContactSheet,
                                    icon: Icon(
                                      Icons.email_outlined,
                                      color: _DetailColors.textSecondary,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Email',
                                      style: TextStyle(color: _DetailColors.textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: _DetailColors.divider),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: _toggleCart,
                                    icon: Icon(
                                      _isInCart ? Icons.remove_shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                                      color: _isInCart ? _DetailColors.textMuted : _DetailColors.bordo,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _isInCart ? 'Ukloni' : 'Korpa',
                                      style: TextStyle(
                                        color: _isInCart ? _DetailColors.textMuted : _DetailColors.bordo,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: _isInCart ? _DetailColors.divider : _DetailColors.bordo.withOpacity(0.4),
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // === OWNER ACTIONS ===
                        if (_isOwner) ...[
                          if (!_isSold)
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _isMarkingSold ? null : _confirmMarkAsSold,
                                icon: _isMarkingSold
                                    ? const SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check_circle_outline_rounded, size: 20),
                                label: Text(
                                  _isMarkingSold ? 'Oznacavanje...' : 'OZNACI KAO PRODANO',
                                  style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _DetailColors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),

                          if (!_isSold) const SizedBox(height: 12),

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
                                side: BorderSide(color: Colors.red.shade400.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],

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
                color: _DetailColors.surface,
                child: const Center(child: CircularProgressIndicator(color: _DetailColors.bordo, strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: _DetailColors.surface,
                child: const Icon(Icons.broken_image_rounded, color: _DetailColors.textMuted, size: 48),
              ),
            );
          },
        ),

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
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isActive
                        ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)]
                        : [],
                  ),
                );
              }),
            ),
          ),

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
      color: _DetailColors.surface,
      child: Center(
        child: Icon(Icons.shopping_bag_outlined, size: 64, color: _DetailColors.bordo.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _DetailColors.bordo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DetailColors.bordo.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _DetailColors.bordo),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _DetailColors.textPrimary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'];
    return '${date.day}. ${months[date.month - 1]} ${date.year}.';
  }
}
