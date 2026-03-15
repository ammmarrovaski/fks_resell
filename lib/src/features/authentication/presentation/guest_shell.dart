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
  static const Color navBg = Color(0xFF1E1E1E);
  static const Color inactive = Color(0xFF666666);

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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              tab.lockedMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bordo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('PRIJAVITE SE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: bordo.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('REGISTRUJTE SE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1, color: bordo)),
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
          const HomeScreen(),
          if (_selectedIndex != 0)
            _buildLockedOverlay(_tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                // Shop
                _GuestNavItem(
                  icon: _tabs[0].icon,
                  selectedIcon: _tabs[0].selectedIcon,
                  label: _tabs[0].label,
                  selected: _selectedIndex == 0,
                  locked: false,
                  onTap: () => _onTabSelected(0),
                ),
                // Poruke
                _GuestNavItem(
                  icon: _tabs[2].icon,
                  selectedIcon: _tabs[2].selectedIcon,
                  label: _tabs[2].label,
                  selected: _selectedIndex == 2,
                  locked: true,
                  onTap: () => _onTabSelected(2),
                ),

                // Objavi — srednje, istaknuto
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabSelected(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _selectedIndex == 1
                                ? bordo
                                : bordo.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: bordo.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: _selectedIndex == 1
                                ? [BoxShadow(color: bordo.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)]
                                : [],
                          ),
                          child: Icon(
                            _selectedIndex == 1 ? Icons.add_box : Icons.add_box_outlined,
                            color: _selectedIndex == 1 ? Colors.white : bordo,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Objavi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _selectedIndex == 1 ? bordo : inactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Obavještenja
                _GuestNavItem(
                  icon: _tabs[3].icon,
                  selectedIcon: _tabs[3].selectedIcon,
                  label: _tabs[3].label,
                  selected: _selectedIndex == 3,
                  locked: true,
                  onTap: () => _onTabSelected(3),
                ),
                // Profil
                _GuestNavItem(
                  icon: _tabs[4].icon,
                  selectedIcon: _tabs[4].selectedIcon,
                  label: _tabs[4].label,
                  selected: _selectedIndex == 4,
                  locked: true,
                  onTap: () => _onTabSelected(4),
                ),
              ],
            ),
          ),
        ),
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
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tab.lockedMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: textSecondary, height: 1.6),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('PRIJAVITE SE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: bordo.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('REGISTRUJTE SE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1, color: bordo)),
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

class _GuestNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  static const Color bordo = Color(0xFF722F37);
  static const Color active = Color(0xFF722F37);
  static const Color inactive = Color(0xFF666666);

  const _GuestNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: locked ? inactive.withOpacity(0.5) : (selected ? active : inactive),
                  size: 24,
                ),
                if (locked)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: inactive.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, size: 7, color: Colors.white54),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: locked ? inactive.withOpacity(0.5) : (selected ? active : inactive),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
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