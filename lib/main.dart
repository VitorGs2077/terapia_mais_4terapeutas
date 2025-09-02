import 'package:flutter/material.dart';
import 'package:terapia_mais_4terapeutas/telas/telaLogin.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Telalogin(),
    );
  }
}
