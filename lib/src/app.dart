import 'package:flutter/material.dart';
import 'features/authentication/presentation/login_screen.dart';

class App extends StatelessWidget {
  final String flavor;

  const App({Key? key, required this.flavor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FKS Resell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF722F37),
          brightness: Brightness.dark,
          surface: const Color(0xFF242424),
          onSurface: const Color(0xFFF5F5F5),
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF242424),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF722F37),
              );
            }
            return const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            );
          }),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
