import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/presentation/login_screen.dart';
import 'features/authentication/presentation/guest_shell.dart';
import 'features/authentication/presentation/onboarding_screen.dart';
 
class App extends StatelessWidget {
  final String flavor;
 
  const App({Key? key, required this.flavor}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FKS Resell',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
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
            return const TextStyle(fontSize: 12, color: Color(0xFF666666));
          }),
        ),
      ),
      home: const _AppEntry(),
    );
  }
}
 
class _AppEntry extends StatefulWidget {
  const _AppEntry();
 
  @override
  State<_AppEntry> createState() => _AppEntryState();
}
 
class _AppEntryState extends State<_AppEntry> {
  bool _loading = true;
  bool _showOnboarding = false;
 
  @override
  void initState() {
    super.initState();
    _loading = false;
    _showOnboarding = true;
  }
 
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF722F37),
            strokeWidth: 2.5,
          ),
        ),
      );
    }
 
    return _showOnboarding ? const OnboardingScreen() : const GuestShell();
  }
}