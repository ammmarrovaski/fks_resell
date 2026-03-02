import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../../shop/presentation/add_product_screen.dart';

// Bordo boje za FK Sarajevo temu
class _ShellColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF666666);
}

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _switchToShop() {
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    // Build screens inside build so callbacks work with current state
    final List<Widget> screens = [
      const HomeScreen(),
      AddProductScreen(onPublished: _switchToShop),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _ShellColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _ShellColors.cardBg,
          border: Border(
            top: BorderSide(
              color: _ShellColors.textMuted.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: _ShellColors.cardBg,
          indicatorColor: _ShellColors.bordo.withOpacity(0.2),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() => _selectedIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined, color: _ShellColors.textMuted),
              selectedIcon: Icon(Icons.storefront, color: _ShellColors.bordo),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: _ShellColors.textMuted),
              selectedIcon: Icon(Icons.add_circle, color: _ShellColors.bordo),
              label: 'Objavi',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: _ShellColors.textMuted),
              selectedIcon: Icon(Icons.person, color: _ShellColors.bordo),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
