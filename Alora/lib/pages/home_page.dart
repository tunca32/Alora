import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ana Sayfa")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hoş Geldiniz!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Satıcı Olmak İster Misiniz?"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Bize ulaşmak için:"),
                        const SizedBox(height: 10),
                        const SelectableText("📧 alora.destek@gmail.com"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              'assets/instagram.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const SelectableText("@alora.official"),
                          ],
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Kapat"),
                      )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.store),
              label: const Text("Satıcı mı olmak istiyorsunuz?"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

