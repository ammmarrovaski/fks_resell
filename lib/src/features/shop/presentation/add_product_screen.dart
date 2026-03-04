import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/shop_repository.dart';

class _AppColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color success = Color(0xFF2E7D32);
}

class AddProductScreen extends StatefulWidget {
  final VoidCallback? onPublished;
  const AddProductScreen({Key? key, this.onPublished}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shopRepo = ShopRepository();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  String _selectedCategory = 'Dresovi';
  String _selectedCondition = 'Novo';
  bool _isLoading = false;
  bool _publishSuccess = false;
  String _loadingMessage = '';
  final List<File> _selectedImages = [];
  static const int _maxImages = 5;

  final List<String> _categories = ['Dresovi', 'Duksevi', 'Salovi', 'Aksesoari'];
  final List<String> _conditions = ['Novo', 'Kao novo', 'Koristeno'];

  final Map<String, IconData> _categoryIcons = {
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.dry_cleaning,
    'Aksesoari': Icons.watch,
  };

  void _showImageSourceSheet() {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maksimalno $_maxImages slika'),
          backgroundColor: _AppColors.bordo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dodaj sliku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _AppColors.bordo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: _AppColors.bordo),
                ),
                title: const Text('Kamera', style: TextStyle(color: _AppColors.textPrimary)),
                subtitle: const Text('Uslikaj novi artikal', style: TextStyle(color: _AppColors.textMuted, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _AppColors.bordo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _AppColors.bordo),
                ),
                title: const Text('Galerija', style: TextStyle(color: _AppColors.textPrimary)),
                subtitle: const Text('Izaberi iz galerije', style: TextStyle(color: _AppColors.textMuted, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedImages.add(File(picked.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska pri odabiru slike: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _objaviArtikal() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;
    final description = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Priprema...';
    });

    try {
      // Upload images first if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        setState(() => _loadingMessage = 'Upload slika (${_selectedImages.length})...');
        imageUrls = await _shopRepo.uploadImages(_selectedImages);
      }

      // Then create product
      setState(() => _loadingMessage = 'Objava artikla...');
      await _shopRepo.addProduct(
        title,
        price,
        _selectedCategory,
        imageUrls: imageUrls,
        description: description,
        condition: _selectedCondition,
      );

      if (mounted) {
        setState(() {
          _publishSuccess = true;
          _isLoading = false;
          _loadingMessage = '';
        });

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() => _publishSuccess = false);
          _titleController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _selectedImages.clear();
          _formKey.currentState?.reset();
          widget.onPublished?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greska: $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: _publishSuccess ? _buildSuccessState() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _AppColors.success.withOpacity(0.15),
              border: Border.all(color: _AppColors.success.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.check_rounded, color: _AppColors.success, size: 50),
          ),
          const SizedBox(height: 24),
          const Text(
            'Artikal objavljen!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vas artikal je sada vidljiv svima.',
            style: TextStyle(fontSize: 15, color: _AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Objavi artikal',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dodaj novi artikal u FKS Fan Shop',
              style: TextStyle(fontSize: 15, color: _AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            // Image picker section
            _buildImageSection(),

            const SizedBox(height: 24),

            // Category chips
            const Text('Kategorija', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _AppColors.bordo.withOpacity(0.2) : _AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _AppColors.bordo : _AppColors.textMuted.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcons[cat] ?? Icons.category,
                          size: 18,
                          color: isSelected ? _AppColors.bordo : _AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? _AppColors.textPrimary : _AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Naziv artikla',
              hint: 'npr. Gostujuci dres 2024/25',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Unesite naziv artikla';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Price + Condition row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Cijena (KM)',
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Unesite cijenu';
                      final price = double.tryParse(value.trim());
                      if (price == null || price <= 0) return 'Nevalidna cijena';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stanje', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _AppColors.textMuted.withOpacity(0.2)),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCondition,
                          dropdownColor: _AppColors.cardBg,
                          style: const TextStyle(color: _AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                          items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => _selectedCondition = val!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Opis (opcionalno)',
              hint: 'Dodajte opis artikla...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Publish button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _objaviArtikal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.bordo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _AppColors.bordo.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _loadingMessage,
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'OBJAVI ARTIKAL',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Slike', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
            Text(
              '${_selectedImages.length}/$_maxImages',
              style: TextStyle(
                fontSize: 13,
                color: _selectedImages.length >= _maxImages ? _AppColors.bordo : _AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (_selectedImages.length < _maxImages)
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _AppColors.bordo.withOpacity(0.4),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _AppColors.bordo.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded, color: _AppColors.bordo, size: 22),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Dodaj sliku',
                          style: TextStyle(fontSize: 12, color: _AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected image thumbnails
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          file,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      // Index badge
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: _AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _AppColors.textMuted),
            prefixIcon: maxLines == 1 ? Icon(icon, color: _AppColors.textMuted, size: 22) : null,
            filled: true,
            fillColor: _AppColors.inputBg,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _AppColors.textMuted.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _AppColors.bordo, width: 2),
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
}
