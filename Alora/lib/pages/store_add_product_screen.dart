import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoreAddProductScreen extends StatefulWidget {
  const StoreAddProductScreen({Key? key}) : super(key: key);

  @override
  State<StoreAddProductScreen> createState() => _StoreAddProductScreenState();
}

class _StoreAddProductScreenState extends State<StoreAddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String _message = '';

  Future<String?> _getStoreIdForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final storeQuery = await FirebaseFirestore.instance
        .collection('stores')
        .where('ownerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (storeQuery.docs.isEmpty) return null;

    return storeQuery.docs.first.id;
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _message = '';
    });

    try {
      final storeId = await _getStoreIdForCurrentUser();

      if (storeId == null) {
        setState(() {
          _message = 'Mağaza bulunamadı!';
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .add({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _categoryController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _message = 'Ürün başarıyla eklendi!';
      });

      _nameController.clear();
      _priceController.clear();
      _categoryController.clear();
    } catch (e) {
      setState(() {
        _message = 'Hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Ekle'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 24),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('Hata') ? Colors.red : Colors.green,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _addProduct,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ürünü Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

