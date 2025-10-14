import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';
import 'package:terapia_mais_4terapeutas/telas/login/tela_login.dart';
import 'package:terapia_mais_4terapeutas/telas/login/teste.dart';
import 'package:terapia_mais_4terapeutas/telas/perfil/perfil.dart';

class TelaConfiguracoes extends StatefulWidget {
  final Function(bool)? onThemeChange;
  const TelaConfiguracoes({super.key, this.onThemeChange});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool _notificacoes = false;
  bool _temaEscuro = false;
  bool _isAdmin = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
    _verificarAdmin();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid;

    bool tema = prefs.getBool('temaEscuro') ?? false;
    bool notif = prefs.getBool('notificacoes') ?? false;

    if (_userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('preferencias')
          .doc(_userId)
          .get();
      final dados = doc.data();
      if (dados != null) {
        tema = dados['temaEscuro'] ?? tema;
        notif = dados['notificacoes'] ?? notif;
      }
    }

    setState(() {
      _temaEscuro = tema;
      _notificacoes = notif;
    });

    widget.onThemeChange?.call(_temaEscuro); // aplica o tema salvo
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacoes', _notificacoes);
    await prefs.setBool('temaEscuro', _temaEscuro);

    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('preferencias')
          .doc(_userId)
          .set({
            'notificacoes': _notificacoes,
            'temaEscuro': _temaEscuro,
          }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferências salvas! Reinicie o app para aplicá-las.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Receber notificações do app'),
            value: _notificacoes,
            onChanged: (val) {
              setState(() => _notificacoes = val);
            },
          ),
          SwitchListTile(
            title: const Text('Tema escuro'),
            subtitle: const Text('Ativar modo escuro globalmente'),
            value: _temaEscuro,
            onChanged: (val) {
              setState(() => _temaEscuro = val);
              widget.onThemeChange?.call(val);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_a_photo),
            title: const Text('Editar perfil'),
            subtitle: const Text('Troque as informações do seu perfil'),
            onTap: irPara(context, const TelaEditarPerfil()),
          ),
          ListTile(
            leading: Icon(Icons.save, color: Theme.of(context).primaryColor),
            title: const Text('Salvar preferências'),
            subtitle: const Text('Salvar configurações no servidor'),
            onTap: _salvarPreferencias,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair'),
            subtitle: const Text('Fazer logout da conta'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              irPara(context, const Telalogin(), apagarAnterior: true)();
            },
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Painel Administrativo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Acesso exclusivo para administradores'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    irPara(context, LoginTeste())();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
