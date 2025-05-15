import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alora_app/pages/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alora_app/pages/store_product_list_screen.dart';

class StoreLoginScreen extends StatefulWidget {
  const StoreLoginScreen({Key? key}) : super(key: key);

  @override
  State<StoreLoginScreen> createState() => _StoreLoginScreenState();
}

class _StoreLoginScreenState extends State<StoreLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _error = '';

  Future<void> _loginAsStore() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      final userType = userDoc.data()?['type'];

      if (userType == 'store') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StoreProductListScreen(storeId: userCredential.user!.uid)),
        );
      } else {
        setState(() {
          _error = 'Bu giriş sadece mağaza hesapları içindir.';
        });
        await _auth.signOut(); // Güvenlik için çıkış yap
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = 'Hatalı e-posta veya şifre';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showStoreContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mağaza Başvurusu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mağazanızı eklemek için bizimle iletişime geçin:'),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.email, color: Colors.deepPurple),
                SizedBox(width: 8),
                Expanded(child: Text('destek@alora.com')),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://www.instagram.com/aloraofficial/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  Image.asset('assets/instagram.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  const Text(
                    '@aloraofficial',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mağaza Girişi',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'E-posta giriniz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Şifre giriniz' : null,
                ),
                const SizedBox(height: 24),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _loginAsStore();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Giriş Yap',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _showStoreContactDialog,
                  child: const Text(
                    'Mağazanızı mı eklemek istiyorsunuz? Bizimle iletişime geçin!',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
