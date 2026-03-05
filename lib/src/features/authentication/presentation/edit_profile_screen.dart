import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _EditColors {
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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _nameController;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _user?.displayName ?? '');
    _nameController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final changed = _nameController.text.trim() != (_user?.displayName ?? '');
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _EditColors.red : _EditColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showSnackBar('Ime ne moze biti prazno', isError: true);
      return;
    }

    if (newName.length < 2) {
      _showSnackBar('Ime mora imati najmanje 2 karaktera', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _user?.updateDisplayName(newName);
      await _user?.reload();

      _showSnackBar('Profil uspjesno azuriran');
      if (mounted) {
        setState(() {
          _hasChanges = false;
          _isSaving = false;
        });
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Greska pri cuvanju profila', isError: true);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EditColors.background,
      appBar: AppBar(
        backgroundColor: _EditColors.background,
        foregroundColor: _EditColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Uredi profil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _EditColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: Text(
                  'Sacuvaj',
                  style: TextStyle(
                    color: _isSaving ? _EditColors.textMuted : _EditColors.bordo,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Avatar section
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _EditColors.bordo.withOpacity(0.2),
                    border: Border.all(
                      color: _EditColors.bordo.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: _EditColors.bordo,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      _showSnackBar('Upload profilne slike - uskoro dostupno');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _EditColors.bordo,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _EditColors.background,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              _user?.email ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: _EditColors.textMuted,
              ),
            ),

            const SizedBox(height: 40),

            // Name field
            _buildFieldSection(
              label: 'Ime i prezime',
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: _EditColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Unesite vase ime',
                  hintStyle: const TextStyle(color: _EditColors.textMuted),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: _EditColors.textMuted,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: _EditColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _EditColors.textMuted.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _EditColors.bordo,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email (read-only)
            _buildFieldSection(
              label: 'Email adresa',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _EditColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _EditColors.textMuted.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: _EditColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _user?.email ?? 'Nije dostupno',
                        style: const TextStyle(
                          fontSize: 16,
                          color: _EditColors.textMuted,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _EditColors.textMuted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Ne moze se mijenjati',
                        style: TextStyle(
                          fontSize: 10,
                          color: _EditColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Account created date (read-only)
            _buildFieldSection(
              label: 'Nalog kreiran',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _EditColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _EditColors.textMuted.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: _EditColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _user?.metadata.creationTime != null
                          ? _formatDate(_user!.metadata.creationTime!)
                          : 'Nepoznato',
                      style: const TextStyle(
                        fontSize: 16,
                        color: _EditColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _hasChanges && !_isSaving ? _saveProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _EditColors.bordo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _EditColors.bordo.withOpacity(0.3),
                  disabledForegroundColor: Colors.white.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'SACUVAJ PROMJENE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _EditColors.textSecondary,
            ),
          ),
        ),
        child,
      ],
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _EditColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Odbaciti promjene?',
          style: TextStyle(
            color: _EditColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Imate nesacuvane promjene. Da li zelite da ih odbacite?',
          style: TextStyle(color: _EditColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Nastavi uredjivanje',
              style: TextStyle(color: _EditColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Odbaci',
              style: TextStyle(
                color: _EditColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
