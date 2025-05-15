import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  final String storeId;
  const AddProductScreen({super.key, required this.storeId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String description = '';
  String price = '';

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .collection('products')
          .add({
        'name': name,
        'description': description,
        'price': double.tryParse(price) ?? 0,
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Ürün Adı"),
                validator: (value) => value!.isEmpty ? "Zorunlu alan" : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Açıklama"),
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Fiyat (₺)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Zorunlu alan" : null,
                onSaved: (value) => price = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
