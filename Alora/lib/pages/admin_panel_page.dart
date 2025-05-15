import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Paneli")),
      body: const Center(
        child: Text(
          "Hoş geldin Admin!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
