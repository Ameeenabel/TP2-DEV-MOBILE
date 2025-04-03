import 'package:flutter/material.dart';
import 'screens/home.page.dart'; 
import 'screens/login.page.dart';   

void main() {
  runApp(const ShowApp());
}

class ShowApp extends StatelessWidget {
  const ShowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Show App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const LoginPage(),  // Utilise le nouveau nom
    );
  }
}
