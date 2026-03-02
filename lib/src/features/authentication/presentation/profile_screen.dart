import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// Bordo boje za FK Sarajevo temu
class _ProfileColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _ProfileColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header
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
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: _ProfileColors.bordo,
                ),
              ),

              const SizedBox(height: 16),

              // Email
              Text(
                user?.email ?? 'Gost',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _ProfileColors.textPrimary,
                ),
              ),

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

              // Menu items
              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Moje objave',
                subtitle: 'Pregled vaših artikala',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Omiljeni',
                subtitle: 'Sacuvani artikli',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Postavke',
                subtitle: 'Postavke naloga',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Pomoc',
                subtitle: 'Cesto postavljana pitanja',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // Sign out button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'ODJAVI SE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade400.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
              border: Border.all(
                color: _ProfileColors.textMuted.withOpacity(0.1),
              ),
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
                  child: Icon(
                    icon,
                    color: _ProfileColors.bordo,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _ProfileColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _ProfileColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _ProfileColors.textMuted.withOpacity(0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
