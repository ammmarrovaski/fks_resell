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

              return NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.storefront_outlined),
                    selectedIcon: Icon(Icons.storefront),
                    label: 'Shop',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.add_box_outlined),
                    selectedIcon: Icon(Icons.add_box),
                    label: 'Objavi',
                  ),
                  NavigationDestination(
                    icon: _BadgeIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      count: unreadChats,
                    ),
                    selectedIcon: _BadgeIcon(
                      icon: Icons.chat_bubble_rounded,
                      count: unreadChats,
                      selected: true,
                    ),
                    label: 'Poruke',
                  ),
                  NavigationDestination(
                    icon: _BadgeIcon(
                      icon: Icons.notifications_outlined,
                      count: unreadNotis,
                    ),
                    selectedIcon: _BadgeIcon(
                      icon: Icons.notifications_rounded,
                      count: unreadNotis,
                      selected: true,
                    ),
                    label: 'Obavještenja',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool selected;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF722F37),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
