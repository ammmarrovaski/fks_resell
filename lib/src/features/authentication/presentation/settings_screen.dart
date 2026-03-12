import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class _SettingsColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE53935);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  bool _notificationsEnabled = true;
  bool _isChangingPassword = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _SettingsColors.red : _SettingsColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnackBar('Popunite sva polja', isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar('Nova lozinka mora imati najmanje 6 karaktera', isError: true);
      return;
    }

    if (newPass != confirm) {
      _showSnackBar('Nove lozinke se ne podudaraju', isError: true);
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: current,
      );
      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(newPass);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSnackBar('Lozinka uspjesno promijenjena');
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar('Trenutna lozinka nije ispravna', isError: true);
      } else {
        _showSnackBar('Greska: ${e.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Greska pri promjeni lozinke', isError: true);
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _SettingsColors.cardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _SettingsColors.textMuted.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Promijeni lozinku',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _SettingsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Trenutna lozinka',
                  obscure: _obscureCurrent,
                  onToggle: () {
                    setSheetState(() => _obscureCurrent = !_obscureCurrent);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'Nova lozinka',
                  obscure: _obscureNew,
                  onToggle: () {
                    setSheetState(() => _obscureNew = !_obscureNew);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Potvrdi novu lozinku',
                  obscure: _obscureConfirm,
                  onToggle: () {
                    setSheetState(() => _obscureConfirm = !_obscureConfirm);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChangingPassword
                        ? null
                        : () {
                            _changePassword();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _SettingsColors.bordo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isChangingPassword
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'PROMIJENI LOZINKU',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _SettingsColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _SettingsColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: _SettingsColors.inputBg,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: _SettingsColors.textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _SettingsColors.textMuted.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _SettingsColors.bordo, width: 2),
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _SettingsColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Obrisi nalog?',
          style: TextStyle(
            color: _SettingsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Ova akcija je nepovratna. Svi vasi podaci, objave i historija kupovine ce biti trajno obrisani.',
          style: TextStyle(color: _SettingsColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Odustani',
              style: TextStyle(color: _SettingsColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAccount();
            },
            child: const Text(
              'Obrisi',
              style: TextStyle(
                color: _SettingsColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await _user?.delete();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnackBar(
          'Morate se ponovo prijaviti prije brisanja naloga',
          isError: true,
        );
      } else {
        _showSnackBar('Greska: ${e.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Greska pri brisanju naloga', isError: true);
    }
  }

  Future<void> _resetPassword() async {
    if (_user?.email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _user!.email!);
      _showSnackBar('Link za reset lozinke poslan na ${_user!.email}');
    } catch (e) {
      _showSnackBar('Greska pri slanju linka', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsColors.background,
      appBar: AppBar(
        backgroundColor: _SettingsColors.background,
        foregroundColor: _SettingsColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Postavke',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _SettingsColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Account section
            _buildSectionHeader('NALOG'),
            const SizedBox(height: 12),

            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Email',
              subtitle: _user?.email ?? 'Nije dostupno',
              trailing: const SizedBox.shrink(),
            ),

            _buildSettingsTile(
              icon: Icons.badge_outlined,
              title: 'Ime',
              subtitle: _user?.displayName ?? 'Nije postavljeno',
              trailing: const SizedBox.shrink(),
            ),

            _buildSettingsTile(
              icon: Icons.calendar_today_outlined,
              title: 'Nalog kreiran',
              subtitle: _user?.metadata.creationTime != null
                  ? _formatDate(_user!.metadata.creationTime!)
                  : 'Nepoznato',
              trailing: const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),

            // Security section
            _buildSectionHeader('SIGURNOST'),
            const SizedBox(height: 12),

            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Promijeni lozinku',
              subtitle: 'Azurirajte vasu lozinku',
              onTap: _showChangePasswordSheet,
            ),

            _buildSettingsTile(
              icon: Icons.email_outlined,
              title: 'Reset lozinke putem emaila',
              subtitle: 'Primit cete link na vas email',
              onTap: _resetPassword,
            ),

            const SizedBox(height: 28),

            // Notifications section
            _buildSectionHeader('NOTIFIKACIJE'),
            const SizedBox(height: 12),

            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Push notifikacije',
              subtitle: 'Primajte obavjestenja o novim artiklima',
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _showSnackBar(
                  val ? 'Notifikacije ukljucene' : 'Notifikacije iskljucene',
                );
              },
            ),

            const SizedBox(height: 28),

            // App info section
            _buildSectionHeader('APLIKACIJA'),
            const SizedBox(height: 12),

            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Verzija aplikacije',
              subtitle: '1.0.0',
              trailing: const SizedBox.shrink(),
            ),

            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Uslovi koristenja',
              subtitle: 'Procitajte nase uslove',
              onTap: () {
                _showSnackBar('Uskoro dostupno');
              },
            ),

            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Politika privatnosti',
              subtitle: 'Kako koristimo vase podatke',
              onTap: () {
                _showSnackBar('Uskoro dostupno');
              },
            ),

            const SizedBox(height: 28),

            // Danger zone
            _buildSectionHeader('OPASNA ZONA'),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: _SettingsColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _SettingsColors.red.withOpacity(0.2)),
              ),
              child: _buildSettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Obrisi nalog',
                subtitle: 'Trajno uklonite vas nalog i sve podatke',
                iconColor: _SettingsColors.red,
                titleColor: _SettingsColors.red,
                onTap: _confirmDeleteAccount,
                hasBorder: false,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _SettingsColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    bool hasBorder = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: hasBorder ? _SettingsColors.cardBg : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: hasBorder
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _SettingsColors.textMuted.withOpacity(0.1),
                    ),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? _SettingsColors.bordo).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? _SettingsColors.bordo,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? _SettingsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _SettingsColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _SettingsColors.textMuted.withOpacity(0.5),
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _SettingsColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _SettingsColors.textMuted.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _SettingsColors.bordo.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _SettingsColors.bordo, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _SettingsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _SettingsColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _SettingsColors.bordo,
              activeTrackColor: _SettingsColors.bordo.withOpacity(0.3),
              inactiveThumbColor: _SettingsColors.textMuted,
              inactiveTrackColor: _SettingsColors.textMuted.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'januar', 'februar', 'mart', 'april', 'maj', 'juni',
      'juli', 'august', 'septembar', 'oktobar', 'novembar', 'decembar'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}.';
  }
}