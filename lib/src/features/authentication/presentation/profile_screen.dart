import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shop/data/shop_repository.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import 'login_screen.dart';
import 'my_listings_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'purchased_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'edit_profile_screen.dart';
import 'statistics_screen.dart';

class _ProfileColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final shopRepo = ShopRepository();
    final userRepo = UserRepository();

    return StreamBuilder<UserModel?>(
      stream: user != null ? userRepo.watchUser(user.uid) : const Stream.empty(),
      builder: (context, snapshot) {
        final userModel = snapshot.data;

        return Scaffold(
          backgroundColor: _ProfileColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _ProfileColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _ProfileColors.bordo.withOpacity(0.2),
                          border: Border.all(
                            color: _ProfileColors.bordo.withOpacity(0.5),
                            width: 2,
                          ),
                          image: userModel?.profilnaSlika != null
                              ? DecorationImage(
                                  image: NetworkImage(userModel!.profilnaSlika!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: userModel?.profilnaSlika == null
                            ? const Icon(Icons.person_rounded, size: 44, color: _ProfileColors.bordo)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _ProfileColors.bordo,
                              shape: BoxShape.circle,
                              border: Border.all(color: _ProfileColors.background, width: 2.5),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    userModel?.punoIme.isNotEmpty == true
                        ? userModel!.punoIme
                        : user?.displayName ?? user?.email ?? 'Gost',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _ProfileColors.textPrimary,
                    ),
                  ),

                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email!,
                      style: const TextStyle(fontSize: 13, color: _ProfileColors.textMuted),
                    ),
                  ],

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _ProfileColors.bordo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Bordo porodica',
                      style: TextStyle(
                        fontSize: 12,
                        color: _ProfileColors.bordoLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AKTIVNOSTI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ProfileColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<int>(
                    stream: user != null
                        ? shopRepo.getProductsByUser(user.uid).map((list) => list.length)
                        : Stream.value(0),
                    builder: (context, snapshot) {
                      return _buildMenuItem(
                        context: context,
                        icon: Icons.shopping_bag_outlined,
                        title: 'Moje objave',
                        subtitle: 'Pregled vasih artikala',
                        count: snapshot.data ?? 0,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyListingsScreen())),
                      );
                    },
                  ),

                  StreamBuilder<int>(
                    stream: shopRepo.getFavoritesCount(),
                    builder: (context, snapshot) {
                      return _buildMenuItem(
                        context: context,
                        icon: Icons.favorite_outline,
                        title: 'Omiljeni',
                        subtitle: 'Sacuvani artikli',
                        count: snapshot.data ?? 0,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                      );
                    },
                  ),

                  StreamBuilder<int>(
                    stream: shopRepo.getCartCount(),
                    builder: (context, snapshot) {
                      return _buildMenuItem(
                        context: context,
                        icon: Icons.shopping_cart_outlined,
                        title: 'Korpa',
                        subtitle: 'Artikli u vasoj korpi',
                        count: snapshot.data ?? 0,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                      );
                    },
                  ),

                  StreamBuilder<int>(
                    stream: shopRepo.getPurchasedCount(),
                    builder: (context, snapshot) {
                      return _buildMenuItem(
                        context: context,
                        icon: Icons.receipt_long_outlined,
                        title: 'Kupljeni artikli',
                        subtitle: 'Historija kupovine',
                        count: snapshot.data ?? 0,
                        countColor: _ProfileColors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasedScreen())),
                      );
                    },
                  ),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistika',
                    subtitle: 'Pregled vase aktivnosti',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen())),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'OSTALO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ProfileColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Postavke',
                    subtitle: 'Postavke naloga',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Pomoc',
                    subtitle: 'Cesto postavljana pitanja',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'ODJAVI SE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade400.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int count = 0,
    Color? countColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _ProfileColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _ProfileColors.textMuted.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _ProfileColors.bordo.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _ProfileColors.bordo, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _ProfileColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: _ProfileColors.textMuted)),
                    ],
                  ),
                ),
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (countColor ?? _ProfileColors.bordo).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: countColor ?? _ProfileColors.bordo),
                    ),
                  ),
                Icon(Icons.chevron_right_rounded, color: _ProfileColors.textMuted.withOpacity(0.5), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}