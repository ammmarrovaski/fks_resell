import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../../shop/presentation/add_product_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../chat/data/chat_repository.dart';
import '../../notifications/data/notification_repository.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final _chatRepo = ChatRepository();
  final _notiRepo = NotificationRepository();

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddProductScreen(),
    const ChatListScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  static const Color _bordo = Color(0xFF722F37);
  static const Color _navBg = Color(0xFF1E1E1E);
  static const Color _active = Color(0xFF722F37);
  static const Color _inactive = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: _chatRepo.getTotalUnreadCount(),
        builder: (context, chatSnapshot) {
          final unreadChats = chatSnapshot.data ?? 0;

          return StreamBuilder<int>(
            stream: _notiRepo.getUnreadCount(),
            builder: (context, notiSnapshot) {
              final unreadNotis = notiSnapshot.data ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: _navBg,
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
                        _NavItem(
                          icon: Icons.storefront_outlined,
                          selectedIcon: Icons.storefront,
                          label: 'Shop',
                          selected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        // Poruke
                        _NavItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          selectedIcon: Icons.chat_bubble_rounded,
                          label: 'Poruke',
                          selected: _selectedIndex == 2,
                          badge: unreadChats,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),

                        // Objavi — srednje, istaknuto
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = 1),
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
                                        ? _bordo
                                        : _bordo.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _bordo.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: _selectedIndex == 1
                                        ? [
                                            BoxShadow(
                                              color: _bordo.withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    _selectedIndex == 1
                                        ? Icons.add_box
                                        : Icons.add_box_outlined,
                                    color: _selectedIndex == 1
                                        ? Colors.white
                                        : _bordo,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Objavi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == 1
                                        ? _active
                                        : _inactive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Obavještenja
                        _NavItem(
                          icon: Icons.notifications_outlined,
                          selectedIcon: Icons.notifications_rounded,
                          label: 'Obavještenja',
                          selected: _selectedIndex == 3,
                          badge: unreadNotis,
                          onTap: () => setState(() => _selectedIndex = 3),
                        ),
                        // Profil
                        _NavItem(
                          icon: Icons.person_outline,
                          selectedIcon: Icons.person,
                          label: 'Profil',
                          selected: _selectedIndex == 4,
                          onTap: () => setState(() => _selectedIndex = 4),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  static const Color _active = Color(0xFF722F37);
  static const Color _inactive = Color(0xFF666666);

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
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
                  color: selected ? _active : _inactive,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _active,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1E1E1E),
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                color: selected ? _active : _inactive,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}