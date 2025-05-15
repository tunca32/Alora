import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;
  String _error = '';

  Future<void> _createStoreAccount() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      String uid = userCredential.user!.uid;


      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'type': 'store',
        'storeName': _storeNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'city': _cityController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mağaza hesabı başarıyla oluşturuldu')),
      );


      _emailController.clear();
      _passwordController.clear();
      _storeNameController.clear();
      _descriptionController.clear();
      _cityController.clear();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Bir hata oluştu';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Mağaza Hesabı Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Mağaza E-posta'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(labelText: 'Mağaza Adı'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Şehir'),
            ),
            const SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _createStoreAccount,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Mağaza Hesabı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
