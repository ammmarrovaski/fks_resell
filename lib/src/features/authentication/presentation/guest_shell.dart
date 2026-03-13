import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../../features/shop/presentation/seller_profile_screen.dart';

class GuestShell extends StatefulWidget {
  const GuestShell({Key? key}) : super(key: key);

  @override
  State<GuestShell> createState() => _GuestShellState();
}

class _GuestShellState extends State<GuestShell> {
  int _selectedIndex = 0;

  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);

  final List<_TabConfig> _tabs = [
    _TabConfig(
      label: 'Shop',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      locked: false,
    ),
    _TabConfig(
      label: 'Objavi',
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box,
      locked: true,
      lockedTitle: 'Objavite artikal',
      lockedMessage: 'Prijavite se ili registrujte da biste mogli objaviti artikal.',
    ),
    _TabConfig(
      label: 'Poruke',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      locked: true,
      lockedTitle: 'Vaše poruke',
      lockedMessage: 'Prijavite se ili registrujte da biste mogli slati i primati poruke.',
    ),
    _TabConfig(
      label: 'Obavještenja',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      locked: true,
      lockedTitle: 'Obavještenja',
      lockedMessage: 'Prijavite se ili registrujte da biste primali obavještenja.',
    ),
    _TabConfig(
      label: 'Profil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      locked: true,
      lockedTitle: 'Vaš profil',
      lockedMessage: 'Prijavite se ili registrujte da biste pristupili svom profilu.',
    ),
  ];

  void _onTabSelected(int index) {
    if (_tabs[index].locked) {
      _showAuthSheet(_tabs[index]);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _showAuthSheet(_TabConfig tab) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bordo.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: bordo.withOpacity(0.25)),
              ),
              child: const Icon(Icons.lock_rounded, color: bordo, size: 28),
            ),
            const SizedBox(height: 16),

            Text(
              tab.lockedTitle ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tab.lockedMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bordo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'PRIJAVITE SE',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: bordo.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'REGISTRUJTE SE',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: bordo,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Only show home screen (index 0)
          const HomeScreen(),

          // Blur overlay for locked tabs
          if (_selectedIndex != 0)
            _buildLockedOverlay(_tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: _tabs.map((tab) {
          final isLocked = tab.locked;
          return NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(tab.icon, color: isLocked ? textMuted.withOpacity(0.5) : null),
                if (isLocked)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: textMuted.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, size: 8, color: Colors.white54),
                    ),
                  ),
              ],
            ),
            selectedIcon: Icon(tab.selectedIcon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLockedOverlay(_TabConfig tab) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: background.withOpacity(0.85),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: bordo.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: bordo.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.lock_rounded, color: bordo, size: 36),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tab.lockedTitle ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tab.lockedMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _showAuthSheet(tab),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bordo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'PRIJAVITE SE',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: bordo.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'REGISTRUJTE SE',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: bordo,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool locked;
  final String? lockedTitle;
  final String? lockedMessage;

  const _TabConfig({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.locked,
    this.lockedTitle,
    this.lockedMessage,
  });
}