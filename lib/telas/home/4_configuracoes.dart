import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';
import 'package:terapia_mais_4terapeutas/telas/login/teste.dart';

class telaConfiguracoes extends StatefulWidget {
  const telaConfiguracoes({super.key});

  @override
  State<telaConfiguracoes> createState() => _telaConfiguracoesState();
}

class _telaConfiguracoesState extends State<telaConfiguracoes> {
  bool _notificacoes = false;
  bool _temaEscuro = false;
  bool _isAdmin = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_userId)
          .get();
      setState(() {
        _isAdmin = doc.data()?['admin'] == true;
      });
    }
  }

  Future<void> _salvarPreferencias() async {
    await FirebaseFirestore.instance
        .collection('preferencias')
        .doc(_userId ?? 'usuario_demo')
        .set({'notificacoes': _notificacoes, 'temaEscuro': _temaEscuro});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Preferências salvas!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notificações'),
            value: _notificacoes,
            onChanged: (val) {
              setState(() => _notificacoes = val);
            },
          ),
          SwitchListTile(
            title: Text('Tema escuro'),
            value: _temaEscuro,
            onChanged: (val) {
              setState(() => _temaEscuro = val);
            },
          ),
          ListTile(
            leading: Icon(Icons.save),
            title: Text('Salvar preferências'),
            onTap: _salvarPreferencias,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sair'),
            onTap: () {
              // ação de logout
            },
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0,
              ),
              child: ElevatedButton.icon(
                icon: Icon(Icons.admin_panel_settings),
                label: Text('Botão exclusivo do admin'),
                onPressed: () {
                  irPara(context, LoginTeste())();
                },
              ),
            ),
        ],
      ),
    );
  }
}
