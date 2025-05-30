import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/role_selection_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İkinci El Bilgisayar Satış',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //
      home: RoleSelectionPage(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupPage(),
        '/roles': (context) => RoleSelectionPage(),
      },
    );
  }
}







