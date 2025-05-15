import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAddStoreScreen extends StatefulWidget {
  const AdminAddStoreScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddStoreScreen> createState() => _AdminAddStoreScreenState();
}

class _AdminAddStoreScreenState extends State<AdminAddStoreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String _message = '';

  Future<void> _addStore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _message = '';
    });

    try {
      await _firestore.collection('stores').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'city': _cityController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _message = 'Mağaza başarıyla eklendi!';
      });

      _nameController.clear();
      _descriptionController.clear();
      _cityController.clear();
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
        title: const Text('Mağaza Ekle (Admin)'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Mağaza Adı'),
                validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Şehir'),
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
                onPressed: _isSaving ? null : _addStore,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Mağazayı Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
