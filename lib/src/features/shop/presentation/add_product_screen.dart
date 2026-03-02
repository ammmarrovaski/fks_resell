import 'package:flutter/material.dart';
import '../data/shop_repository.dart';

// Bordo boje za FK Sarajevo temu
class _AppColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color success = Color(0xFF2E7D32);
}

class AddProductScreen extends StatefulWidget {
  /// Optional callback to switch tab after successful publish
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

  String _selectedCategory = 'Dresovi';
  String _selectedCondition = 'Novo';
  bool _isLoading = false;
  bool _publishSuccess = false;

  final List<String> _categories = ['Dresovi', 'Duksevi', 'Salovi', 'Aksesoari'];
  final List<String> _conditions = ['Novo', 'Kao novo', 'Korišteno'];

  final Map<String, IconData> _categoryIcons = {
    'Dresovi': Icons.sports_soccer,
    'Duksevi': Icons.checkroom,
    'Salovi': Icons.scarf,
    'Aksesoari': Icons.watch,
  };

  void _objaviArtikal() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;

    setState(() => _isLoading = true);

    try {
      await _shopRepo.addProduct(title, price, _selectedCategory);
      if (mounted) {
        setState(() {
          _publishSuccess = true;
          _isLoading = false;
        });

        // Show success state briefly, then reset the form
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() => _publishSuccess = false);
          _titleController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _formKey.currentState?.reset();

          // Switch to Shop tab if callback is provided
          widget.onPublished?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
            child: const Icon(
              Icons.check_rounded,
              color: _AppColors.success,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Artikal objavljen!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vas artikal je sada vidljiv svima.',
            style: TextStyle(
              fontSize: 15,
              color: _AppColors.textSecondary,
            ),
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

            // Header
            const Text(
              'Objavi artikal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dodaj novi artikal u FKS Fan Shop',
              style: TextStyle(
                fontSize: 15,
                color: _AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // Category selection chips
            const Text(
              'Kategorija',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _AppColors.textSecondary,
              ),
            ),
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
                      color: isSelected
                          ? _AppColors.bordo.withOpacity(0.2)
                          : _AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _AppColors.bordo
                            : _AppColors.textMuted.withOpacity(0.2),
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
                            color: isSelected
                                ? _AppColors.textPrimary
                                : _AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Title field
            _buildTextField(
              controller: _titleController,
              label: 'Naziv artikla',
              hint: 'npr. Gostujuci dres 2024/25',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite naziv artikla';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Price and Condition row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Cijena (KM)',
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unesite cijenu';
                      }
                      final price = double.tryParse(value.trim());
                      if (price == null || price <= 0) {
                        return 'Nevalidna cijena';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stanje',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _AppColors.textMuted.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCondition,
                          dropdownColor: _AppColors.cardBg,
                          style: const TextStyle(
                            color: _AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                          items: _conditions.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCondition = val!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Description field
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'OBJAVI ARTIKAL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _AppColors.textSecondary,
          ),
        ),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _AppColors.textMuted.withOpacity(0.2),
              ),
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
