import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shop/data/shop_repository.dart';
import '../../shop/domain/product.dart';

class _StatsColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF42A5F5);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFFAB47BC);
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final shopRepo = ShopRepository();

    return Scaffold(
      backgroundColor: _StatsColors.background,
      appBar: AppBar(
        backgroundColor: _StatsColors.background,
        foregroundColor: _StatsColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Statistika',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _StatsColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Morate biti prijavljeni.',
                style: TextStyle(color: _StatsColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Purchased stats
                  _buildSectionHeader('KUPOVINA'),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Product>>(
                    stream: shopRepo.getPurchasedProducts(),
                    builder: (context, snapshot) {
                      final products = snapshot.data ?? [];
                      final totalSpent = products.fold<double>(
                        0,
                        (sum, p) => sum + p.price,
                      );
                      final avgPrice = products.isNotEmpty
                          ? totalSpent / products.length
                          : 0.0;

                      // Category breakdown
                      final categoryCount = <String, int>{};
                      for (final p in products) {
                        categoryCount[p.category] =
                            (categoryCount[p.category] ?? 0) + 1;
                      }

                      final mostBoughtCategory = categoryCount.isNotEmpty
                          ? categoryCount.entries
                              .reduce((a, b) => a.value > b.value ? a : b)
                              .key
                          : 'N/A';

                      return Column(
                        children: [
                          // Main stats cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.shopping_bag_rounded,
                                  iconColor: _StatsColors.bordo,
                                  title: 'Kupljeno',
                                  value: '${products.length}',
                                  subtitle: 'artikala',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.payments_rounded,
                                  iconColor: _StatsColors.green,
                                  title: 'Potroseno',
                                  value: '${totalSpent.toStringAsFixed(0)} KM',
                                  subtitle: 'ukupno',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.analytics_rounded,
                                  iconColor: _StatsColors.blue,
                                  title: 'Prosjek',
                                  value: '${avgPrice.toStringAsFixed(0)} KM',
                                  subtitle: 'po artiklu',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.category_rounded,
                                  iconColor: _StatsColors.orange,
                                  title: 'Najcesca',
                                  value: mostBoughtCategory,
                                  subtitle: 'kategorija',
                                ),
                              ),
                            ],
                          ),

                          if (categoryCount.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildCategoryBreakdown(categoryCount, products.length),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Selling stats
                  _buildSectionHeader('PRODAJA'),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Product>>(
                    stream: shopRepo.getProductsByUser(user.uid),
                    builder: (context, snapshot) {
                      final products = snapshot.data ?? [];
                      final soldProducts =
                          products.where((p) => p.isSold).toList();
                      final activeProducts =
                          products.where((p) => !p.isSold).toList();
                      final totalEarned = soldProducts.fold<double>(
                        0,
                        (sum, p) => sum + p.price,
                      );

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.inventory_2_rounded,
                                  iconColor: _StatsColors.bordo,
                                  title: 'Ukupno objava',
                                  value: '${products.length}',
                                  subtitle: 'artikala',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.sell_rounded,
                                  iconColor: _StatsColors.green,
                                  title: 'Prodano',
                                  value: '${soldProducts.length}',
                                  subtitle: 'artikala',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.storefront_rounded,
                                  iconColor: _StatsColors.blue,
                                  title: 'Aktivno',
                                  value: '${activeProducts.length}',
                                  subtitle: 'artikala',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconColor: _StatsColors.orange,
                                  title: 'Zarada',
                                  value:
                                      '${totalEarned.toStringAsFixed(0)} KM',
                                  subtitle: 'ukupno',
                                ),
                              ),
                            ],
                          ),

                          if (products.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildSalesProgress(
                              soldProducts.length,
                              products.length,
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Engagement stats
                  _buildSectionHeader('AKTIVNOST'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: shopRepo.getFavoritesCount(),
                          builder: (context, snapshot) {
                            return _buildStatCard(
                              icon: Icons.favorite_rounded,
                              iconColor: Colors.redAccent,
                              title: 'Omiljeni',
                              value: '${snapshot.data ?? 0}',
                              subtitle: 'sacuvano',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: shopRepo.getCartCount(),
                          builder: (context, snapshot) {
                            return _buildStatCard(
                              icon: Icons.shopping_cart_rounded,
                              iconColor: _StatsColors.purple,
                              title: 'Korpa',
                              value: '${snapshot.data ?? 0}',
                              subtitle: 'artikala',
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Member since card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _StatsColors.bordo,
                          _StatsColors.bordoLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Clan od',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.metadata.creationTime != null
                                    ? _formatDate(user.metadata.creationTime!)
                                    : 'Nepoznato',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.metadata.creationTime != null
                                    ? '${DateTime.now().difference(user.metadata.creationTime!).inDays} dana u bordo porodici'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _StatsColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _StatsColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _StatsColors.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: _StatsColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _StatsColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: _StatsColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryBreakdown(
    Map<String, int> categoryCount,
    int total,
  ) {
    final sortedEntries = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      _StatsColors.bordo,
      _StatsColors.blue,
      _StatsColors.green,
      _StatsColors.orange,
      _StatsColors.purple,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _StatsColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _StatsColors.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kupljeno po kategoriji',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _StatsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bars
          ...sortedEntries.asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            final percentage = total > 0 ? cat.value / total : 0.0;
            final color = colors[idx % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _StatsColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${cat.value} (${(percentage * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _StatsColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: _StatsColors.inputBg,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildSalesProgress(int sold, int total) {
    final percentage = total > 0 ? sold / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _StatsColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _StatsColors.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stopa prodaje',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _StatsColors.textPrimary,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _StatsColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: _StatsColors.inputBg,
              valueColor:
                  const AlwaysStoppedAnimation(_StatsColors.green),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$sold od $total artikala prodano',
            style: const TextStyle(
              fontSize: 12,
              color: _StatsColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'januar', 'februar', 'mart', 'april', 'maj', 'juni',
      'juli', 'august', 'septembar', 'oktobar', 'novembar', 'decembar'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}.';
  }
}
