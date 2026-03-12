import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/shop_repository.dart';
import '../domain/product.dart';

class _AppColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color divider = Color(0xFF333333);
}

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  final _shopRepo = ShopRepository();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late String _selectedCategory;
  late String _selectedCondition;
  bool _isLoading = false;
  String _loadingMessage = '';

  // Existing URLs from Firestore (kept unless removed)
  late List<String> _existingImageUrls;

  // New files picked by user
  final List<File> _newImages = [];

  static const int _maxImages = 5;

  int get _totalImages => _existingImageUrls.length + _newImages.length;

  final List<String> _categories = ['Dresovi', 'Duksevi', 'Salovi', 'Aksesoari'];
  final List<String> _conditions = ['Novo', 'Kao novo', 'Koristeno'];

  final Map<String, IconData> _categoryIcons = {
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.dry_cleaning,
    'Aksesoari': Icons.watch,
  };

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p.title);
    _priceController = TextEditingController(text: p.price.toStringAsFixed(0));
    _descriptionController = TextEditingController(text: p.description);
    _selectedCategory = _categories.contains(p.category) ? p.category : _categories.first;
    _selectedCondition = _conditions.contains(p.condition) ? p.condition : _conditions.first;
    _existingImageUrls = List<String>.from(p.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    if (_totalImages >= _maxImages) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _AppColors.textPrimary),
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
        setState(() => _newImages.add(File(picked.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri odabiru slike: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _sacuvajIzmjene() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final description = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Priprema...';
    });

    try {
      List<String> finalImageUrls = List<String>.from(_existingImageUrls);

      // Upload new images if any
      if (_newImages.isNotEmpty) {
        setState(() => _loadingMessage = 'Upload slika (${_newImages.length})...');
        final newUrls = await _shopRepo.uploadImages(_newImages);
        finalImageUrls.addAll(newUrls);
      }

      setState(() => _loadingMessage = 'Čuvanje izmjena...');
      await _shopRepo.updateProduct(
        widget.product.id,
        title,
        price,
        _selectedCategory,
        imageUrls: finalImageUrls,
        description: description,
        condition: _selectedCondition,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Artikal uspješno ažuriran!'),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true); // return true = refresh needed
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        backgroundColor: _AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _AppColors.divider),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Uredi artikal',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image section
            _buildImageSection(),

            const SizedBox(height: 24),

            // Category picker
            _buildCategoryPicker(),

            const SizedBox(height: 20),

            // Title
            _buildTextField(
              controller: _titleController,
              label: 'Naziv artikla',
              hint: 'npr. Gostujući dres 2024/25',
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
                      const Text('Stanje',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
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
                          items: _conditions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
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

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sacuvajIzmjene,
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
                          Text(_loadingMessage,
                              style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'SAČUVAJ IZMJENE',
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

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategorija',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: isSelected ? _AppColors.bordo : _AppColors.cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? _AppColors.bordo : _AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _categoryIcons[cat] ?? Icons.category,
                        size: 16,
                        color: isSelected ? Colors.white : _AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : _AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Slike',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
            Text(
              '$_totalImages/$_maxImages',
              style: TextStyle(
                fontSize: 13,
                color: _totalImages >= _maxImages ? _AppColors.bordo : _AppColors.textMuted,
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
              if (_totalImages < _maxImages)
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
                        const Text('Dodaj sliku',
                            style: TextStyle(fontSize: 12, color: _AppColors.textMuted, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),

              // Existing images (from Firestore URLs)
              ..._existingImageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: _AppColors.cardBg,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: _AppColors.bordo, strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: _AppColors.cardBg,
                            child: const Icon(Icons.broken_image_rounded,
                                color: _AppColors.textMuted),
                          ),
                        ),
                      ),
                      // Remove existing image
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _existingImageUrls.removeAt(index)),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
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
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // New images (locally picked files)
              ..._newImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                final displayIndex = _existingImageUrls.length + index;
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
                      ),
                      // "New" badge
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('NOVO',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      // Remove new image
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _newImages.removeAt(index)),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
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
                            '${displayIndex + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: _AppColors.textSecondary)),
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
            prefixIcon: maxLines == 1
                ? Icon(icon, color: _AppColors.textMuted, size: 22)
                : null,
            filled: true,
            fillColor: _AppColors.inputBg,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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