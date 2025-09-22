import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Função para enviar email de redefinição de senha
Future<void> enviarEmailTrocaSenha(BuildContext context, String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Email de redefinição enviado!')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
  }
}

class telaTrocarSenha extends StatefulWidget {
  const telaTrocarSenha({super.key});

  @override
  State<telaTrocarSenha> createState() => telaTrocarSenhaState();
}

class telaTrocarSenhaState extends State<telaTrocarSenha> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              enviarEmailTrocaSenha(context, "vitor.diniz20008@gmail.com");
            },
            child: Text("enviar confirmação para trocar senha"),
          ),
        ],
      ),
    );
  }
}
