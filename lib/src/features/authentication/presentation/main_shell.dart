import 'package:flutter/material.dart';
import 'home_screen.dart'; // Napravit ćemo ga odmah
import '../../shop/presentation/add_product_screen.dart'; // Za objavu artikla

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Lista ekrana kroz koje se navigira
  final List<Widget> _screens = [
    const HomeScreen(),        // Pregled artikala i kategorije
    const AddProductScreen(),   // Objava novog artikla
    const Center(child: Text('Profil i Moje objave')), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Objavi'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}