import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginTeste extends StatefulWidget {
  @override
  _LoginTesteState createState() => _LoginTesteState();
}

class _LoginTesteState extends State<LoginTeste> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  bool _loading = false;
  String? _erro;
  bool _isProfissional = false;
  bool _isAdmin = false; // Novo campo

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
      // Login bem-sucedido
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _criarConta() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text,
          );

      if (cred.user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(cred.user!.uid)
            .set({
              'email': _emailController.text.trim(),
              'profissional': _isProfissional,
              'admin': _isAdmin, // Salva se é admin
              'nome': _nomeController.text.trim().isEmpty ? 'nome_padrao' : _nomeController.text.trim(),
              'numero': _numeroController.text.trim().isEmpty ? '00000-0000' : _numeroController.text.trim(),
            });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
      });
    } on FirebaseException catch (e) {
      setState(() {
        _erro = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(labelText: 'Número'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('É profissional'),
              value: _isProfissional,
              onChanged: (val) {
                setState(() {
                  _isProfissional = val ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text('É admin'),
              value: _isAdmin,
              onChanged: (val) {
                setState(() {
                  _isAdmin = val ?? false;
                });
              },
            ),
            SizedBox(height: 24),
            if (_erro != null)
              Text(_erro!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _criarConta, child: Text('Entrar')),
          ],
        ),
      ),
    );
  }
}
