import 'package:flutter/material.dart';
import '../data/shop_repository.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _shopRepo = ShopRepository();
  
  String _selectedCategory = 'Dresovi';
  bool _isLoading = false;

  final List<String> _categories = ['Dresovi', 'Duksevi', 'Šalovi', 'Aksesoari'];

  void _objaviArtikal() async {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;

    if (title.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite validan naziv i cijenu.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _shopRepo.addProduct(title, price, _selectedCategory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artikal uspješno objavljen!"), backgroundColor: Colors.green),
        );
        _titleController.clear();
        _priceController.clear();
        
        // Automatsko zatvaranje ekrana i vraćanje nazad na prethodni
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bordoColor = Color(0xFF722F37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Objavi artikal"),
        backgroundColor: bordoColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: bordoColor))
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Naziv artikla", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "npr. Gostujući dres",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Cijena (KM)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "100.00",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Kategorija", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _objaviArtikal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bordoColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("POTVRDI OBJAVU"),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}