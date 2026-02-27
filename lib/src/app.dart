import 'package:flutter/material.dart';
import 'features/authentication/presentation/login_screen.dart';

class App extends StatelessWidget {
  final String flavor;

  const App({Key? key, required this.flavor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FKS Resell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D0E1D)), // Bordo boja
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}