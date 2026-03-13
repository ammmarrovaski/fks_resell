import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';
import '../../shop/data/cloudinary_service.dart';

class _C {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE53935);
  static const Color divider = Color(0xFF2E2E2E);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _userRepo = UserRepository();

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _telefonController = TextEditingController();
  final _bioController = TextEditingController();

  UserModel? _userModel;
  String? _selectedSpol;
  DateTime? _selectedDatum;
  File? _newProfilnaSlika;
  bool _isSaving = false;
  bool _isLoading = true;

  static const List<String> _spolovi = ['Muški', 'Ženski', 'Drugo'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _telefonController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (_user == null) return;
    final model = await _userRepo.getUser(_user!.uid);
    if (model != null && mounted) {
      setState(() {
        _userModel = model;
        _imeController.text = model.ime;
        _prezimeController.text = model.prezime;
        _telefonController.text = model.telefon ?? '';
        _bioController.text = model.bio ?? '';
        _selectedSpol = model.spol;
        _selectedDatum = model.datumRodjenja;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _C.red : _C.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickProfilnaSlika() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _newProfilnaSlika = File(picked.path));
    }
  }

  Future<void> _pickDatum() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDatum ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _C.bordo,
            surface: _C.cardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDatum = picked);
  }

  Future<void> _saveProfile() async {
    final ime = _imeController.text.trim();
    final prezime = _prezimeController.text.trim();

    if (ime.isEmpty || prezime.isEmpty) {
      _showSnackBar('Ime i prezime su obavezni', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? profilnaSlikaUrl = _userModel?.profilnaSlika;

      if (_newProfilnaSlika != null) {
        profilnaSlikaUrl = await ImageUploadService.uploadImage(_newProfilnaSlika!);
      }

      await _user?.updateDisplayName('$ime $prezime');

      await _userRepo.updateUser(_user!.uid, {
        'ime': ime,
        'prezime': prezime,
        'telefon': _telefonController.text.trim(),
        'bio': _bioController.text.trim(),
        'spol': _selectedSpol,
        'datumRodjenja': _selectedDatum?.toIso8601String(),
        'profilnaSlika': profilnaSlikaUrl,
      });

      _showSnackBar('Profil uspješno ažuriran!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Greška pri čuvanju profila', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDatum(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Uredi profil',
          style: TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: _C.bordo, strokeWidth: 2),
                    )
                  : const Text(
                      'Sačuvaj',
                      style: TextStyle(color: _C.bordo, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.bordo))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profilna slika
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfilnaSlika,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _C.cardBg,
                              border: Border.all(color: _C.bordo.withOpacity(0.4), width: 2),
                              image: _newProfilnaSlika != null
                                  ? DecorationImage(image: FileImage(_newProfilnaSlika!), fit: BoxFit.cover)
                                  : _userModel?.profilnaSlika != null
                                      ? DecorationImage(image: NetworkImage(_userModel!.profilnaSlika!), fit: BoxFit.cover)
                                      : null,
                            ),
                            child: (_newProfilnaSlika == null && _userModel?.profilnaSlika == null)
                                ? const Icon(Icons.person_rounded, color: _C.textMuted, size: 48)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(color: _C.bordo, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Tapni za promjenu slike', style: TextStyle(color: _C.textMuted, fontSize: 12)),
                  ),
                  const SizedBox(height: 32),

                  _sectionHeader('LIČNI PODACI'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _inputField(_imeController, 'Ime', Icons.person_outline)),
                      const SizedBox(width: 12),
                      Expanded(child: _inputField(_prezimeController, 'Prezime', Icons.person_outline)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _readOnlyField(label: 'Email', value: _user?.email ?? '', icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  _inputField(_telefonController, 'Broj telefona', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _dropdownField(),
                  const SizedBox(height: 12),
                  _datumField(),
                  const SizedBox(height: 24),

                  _sectionHeader('O MENI'),
                  const SizedBox(height: 12),
                  _inputField(_bioController, 'Kratki opis (bio)', Icons.info_outline_rounded, maxLines: 3),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.textMuted, letterSpacing: 1.2),
      );

  Widget _inputField(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.divider),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: _C.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: _C.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
        ),
      ),
    );
  }

  Widget _readOnlyField({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.inputBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: _C.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _C.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: _C.textSecondary, fontSize: 15)),
              ],
            ),
          ),
          const Icon(Icons.lock_rounded, color: _C.textMuted, size: 16),
        ],
      ),
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _C.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.wc_rounded, color: _C.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSpol,
                hint: const Text('Spol', style: TextStyle(color: _C.textMuted, fontSize: 15)),
                dropdownColor: _C.cardBg,
                style: const TextStyle(color: _C.textPrimary, fontSize: 15),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _C.textMuted),
                items: _spolovi.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSpol = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datumField() {
    return GestureDetector(
      onTap: _pickDatum,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _C.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: _C.textMuted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDatum != null ? _formatDatum(_selectedDatum!) : 'Datum rođenja',
                style: TextStyle(color: _selectedDatum != null ? _C.textPrimary : _C.textMuted, fontSize: 15),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _C.textMuted),
          ],
        ),
      ),
    );
  }
}