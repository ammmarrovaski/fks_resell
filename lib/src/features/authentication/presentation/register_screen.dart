import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/auth_repository.dart';

// Bordo boje za FK Sarajevo temu
class AppColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color bordoDark = Color(0xFF5A252C);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepo = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _pokaziPoruku(String tekst, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.bordo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _registrujSe() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptedTerms) {
      _pokaziPoruku("Morate prihvatiti uslove koristenja.", isError: true);
      return;
    }
    
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    setState(() => _isLoading = true);
    final user = await _authRepo.signUp(email, pass);
    setState(() => _isLoading = false);

    if (user != null) {
      _pokaziPoruku("Uspjesna registracija!");
      Navigator.pop(context);
    } else {
      _pokaziPoruku("Registracija nije uspjela.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background slika sa overlay-om
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.darken,
              child: Image.asset(
                'assets/images/fks.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.background);
                },
              ),
            ),
          ),
          
          // Bordo gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.bordo.withOpacity(0.4),
                    AppColors.background.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          
          // Glavni sadrzaj
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildBackButton(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Logo i naslov
                      _buildHeader(),
                      
                      const SizedBox(height: 40),
                      
                      // Register forma
                      _buildRegisterForm(),
                      
                      const SizedBox(height: 30),
                      
                      // Login link
                      _buildLoginLink(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordo.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo container
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.bordo.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/hz.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.sports_soccer,
                  size: 45,
                  color: AppColors.bordo,
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        const Text(
          'Pridruzi se',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Postani dio Bordo porodice',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bordo.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kreiraj nalog',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Email polje
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'vas@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite email adresu';
                }
                if (!value.contains('@')) {
                  return 'Unesite validnu email adresu';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 18),
            
            // Lozinka polje
            _buildTextField(
              controller: _passwordController,
              label: 'Lozinka',
              hint: 'Min. 6 karaktera',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite lozinku';
                }
                if (value.length < 6) {
                  return 'Lozinka mora imati min. 6 karaktera';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 18),
            
            // Potvrda lozinke
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Potvrdi lozinku',
              hint: 'Ponovite lozinku',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Potvrdite lozinku';
                }
                if (value != _passwordController.text) {
                  return 'Lozinke se ne podudaraju';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Terms checkbox
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _acceptedTerms = !_acceptedTerms);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _acceptedTerms ? AppColors.bordo : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _acceptedTerms ? AppColors.bordo : AppColors.textMuted.withOpacity(0.3),
                      ),
                    ),
                    child: _acceptedTerms
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _acceptedTerms = !_acceptedTerms);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Prihvatam '),
                          TextSpan(
                            text: 'uslove koristenja',
                            style: TextStyle(
                              color: AppColors.bordoLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' i '),
                          TextSpan(
                            text: 'politiku privatnosti',
                            style: TextStyle(
                              color: AppColors.bordoLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Register button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registrujSe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.bordo.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'REGISTRUJ SE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bordo, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vec imas nalog? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Prijavi se',
            style: TextStyle(
              color: AppColors.bordoLight,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

