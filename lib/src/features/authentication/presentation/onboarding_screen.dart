import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import 'guest_shell.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _userRepo = UserRepository();

  int _currentPage = 0;
  bool _isLoading = false;
  String? _errorText;

  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.sports_soccer_rounded,
      title: 'Dobrodošli u\nFKS Resell',
      subtitle: 'Jedini marketplace za navijače\nFK Sarajevo — bordo porodicu.',
      gradient: [Color(0xFF722F37), Color(0xFF5A2129)],
    ),
    _OnboardingPage(
      icon: Icons.storefront_rounded,
      title: 'Kupi i prodaj\nbordo opremu',
      subtitle: 'Dresovi, duksevi, salovi, aksesoari.\nPronađi ili objavi artikal za minute.',
      gradient: [Color(0xFF5A2129), Color(0xFF3D1A1E)],
    ),
    _OnboardingPage(
      icon: Icons.chat_rounded,
      title: 'Poveži se sa\nbordo porodicom',
      subtitle: 'Direktna komunikacija sa prodavačima.\nBezbjedno i jednostavno.',
      gradient: [Color(0xFF3D1A1E), Color(0xFF121212)],
    ),
  ];

  // Ukupno stranica = info stranice + forma (ako je prijavljen)
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  bool get _isLastInfoPage => _currentPage == _pages.length - 1;
  bool get _isFormPage => _currentPage == _pages.length;
  int get _totalPages => _isLoggedIn ? _pages.length + 1 : _pages.length;

  @override
  void dispose() {
    _pageController.dispose();
    _imeController.dispose();
    _prezimeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GuestShell()),
    );
  }

  Future<void> _submitForm() async {
    final ime = _imeController.text.trim();
    final prezime = _prezimeController.text.trim();

    if (ime.isEmpty) {
      setState(() => _errorText = 'Unesite ime');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final exists = await _userRepo.userExists(user.uid);
        if (!exists) {
          await _userRepo.createUser(UserModel(
            uid: user.uid,
            email: user.email ?? '',
            ime: ime,
            prezime: prezime,
            profilnaSlika: user.photoURL,
            createdAt: DateTime.now(),
          ));
        } else {
          await _userRepo.updateUser(user.uid, {
            'ime': ime,
            'prezime': prezime,
          });
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = 'Greška pri čuvanju podataka. Pokušajte ponovo.';
        });
      }
    }
  }

  void _nextPage() {
    if (_isFormPage) {
      _submitForm();
      return;
    }

    if (_isLastInfoPage && _isLoggedIn) {
      // Idi na formu
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else if (_isLastInfoPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String get _buttonLabel {
    if (_isFormPage) return 'ZAVRŠI';
    if (_isLastInfoPage && _isLoggedIn) return 'DALJE';
    if (_isLastInfoPage) return 'POČNI';
    return 'DALJE';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              ..._pages.map((p) => _buildInfoPage(p)),
              if (_isLoggedIn) _buildFormPage(),
            ],
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  32, 24, 32, MediaQuery.of(context).padding.bottom + 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? bordo
                              : textMuted.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bordo,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: bordo.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              _buttonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip (samo na info stranicama, ne na formi)
                  if (!_isFormPage && !_isLastInfoPage)
                    GestureDetector(
                      onTap: _completeOnboarding,
                      child: const Text(
                        'Preskoči',
                        style: TextStyle(
                          fontSize: 14,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Skip forma (samo ako je prijavljen i na formi)
                  if (_isFormPage)
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_done', true);
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainShell()),
                        );
                      },
                      child: const Text(
                        'Preskoči za sada',
                        style: TextStyle(
                          fontSize: 14,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page.gradient[0].withOpacity(0.15), background],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: page.gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.gradient[0].withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 48),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: bordo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bordo.withOpacity(0.3)),
                ),
                child: const Text(
                  'FK SARAJEVO • BORDO PORODICA',
                  style: TextStyle(
                    fontSize: 10,
                    color: bordo,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1215), background],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF722F37), Color(0xFF5A2129)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bordo.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),

              const Center(
                child: Text(
                  'Kako se zoveš?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Ove informacije će biti vidljive\nna tvom profilu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: textSecondary, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),

              // Ime
              const Text('Ime *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _imeController,
                style: const TextStyle(color: textPrimary),
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() => _errorText = null),
                decoration: InputDecoration(
                  hintText: 'Npr. Amar',
                  hintStyle: const TextStyle(color: textMuted),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: textMuted, size: 22),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: bordo, width: 2),
                  ),
                  errorText: _errorText,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Prezime
              const Text('Prezime',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _prezimeController,
                style: const TextStyle(color: textPrimary),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Npr. Marović',
                  hintStyle: const TextStyle(color: textMuted),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: textMuted, size: 22),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: bordo, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}