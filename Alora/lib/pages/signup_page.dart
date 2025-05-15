import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordValid(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasPunctuation = password.contains(RegExp(r'[!@#\$&*~.,;:/?%^(){}\[\]\\\-_=+<>]'));
    final hasMinLength = password.length >= 8;

    return hasUppercase && hasDigits && hasPunctuation && hasMinLength;
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isPasswordValid(password)) {
      showMessage(
        'Şifre en az 8 karakter olmalı ve 1 büyük harf, 1 rakam, 1 noktalama işareti içermelidir.',
        Colors.red,
      );
      return;
    }

    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      String uid = userCredential.user!.uid;


      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'type': 'user',
      });

      if (!mounted) return;


      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Başarılı'),
          content: Text('Kayıt işlemi tamamlandı.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      String errorMessage = 'Bilinmeyen bir hata oluştu.';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      showMessage('Kayıt başarısız: $errorMessage', Colors.red);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-Posta',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    hintText: 'Şifre: 1 büyük harf, 1 rakam, 1 noktalama (!@#)',
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: signUp,
                  child: Text('Kayıt Ol'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Zaten bir hesabınız var mı? Giriş Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}











