import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FKS Fan Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Kategorije", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          // Horizontalna lista kategorija
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip("Sve"),
                _buildCategoryChip("Dresovi"),
                _buildCategoryChip("Duksevi"),
                _buildCategoryChip("Šalovi"),
                _buildCategoryChip("Aksesoari"),
              ],
            ),
          ),
          const Expanded(
            child: Center(child: Text("Ovdje će se učitavati artikli iz Firebase-a...")),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}