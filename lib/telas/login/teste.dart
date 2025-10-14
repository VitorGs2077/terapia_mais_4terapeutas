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
  final TextEditingController _enderecoController = TextEditingController();

  bool _loading = false;
  String? _erro;
  bool _isProfissional = false;
  bool _isAdmin = false;
  String? _generoSelecionado;

  // Mapa com os horários por dia da semana
  Map<String, List<Map<String, String>>> _horariosPorDia = {
    'Seg': [],
    'Ter': [],
    'Qua': [],
    'Qui': [],
    'Sex': [],
    'Sab': [],
    'Dom': [],
  };

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
              'admin': _isAdmin,
              'nome': _nomeController.text.trim().isEmpty
                  ? 'nome_padrao'
                  : _nomeController.text.trim(),
              'numero': _numeroController.text.trim().isEmpty
                  ? '00000-0000'
                  : _numeroController.text.trim(),
              'endereco': _enderecoController.text.trim().isEmpty
                  ? 'Rua Desconhecida'
                  : _enderecoController.text.trim(),
              'genero': _generoSelecionado ?? '',

              'horarios': _horariosPorDia, // salva os horários
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

  void _abrirHorarioDialog(String dia) {
    TimeOfDay? inicio;
    TimeOfDay? fim;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Horários para $dia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() {
                            inicio = time;
                          });
                        }
                      },
                      child: Text(
                        inicio == null
                            ? 'Selecionar início'
                            : 'Início: ${inicio!.format(context)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() {
                            fim = time;
                          });
                        }
                      },
                      child: Text(
                        fim == null
                            ? 'Selecionar fim'
                            : 'Fim: ${fim!.format(context)}',
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (inicio != null && fim != null) {
                          setDialogState(() {
                            _horariosPorDia[dia]!.add({
                              'inicio': inicio!.format(context),
                              'fim': fim!.format(context),
                            });
                            inicio = null;
                            fim = null;
                          });
                        }
                      },
                      child: Text('Adicionar intervalo'),
                    ),
                    SizedBox(height: 16),
                    if (_horariosPorDia[dia]!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _horariosPorDia[dia]!.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final intervalo = entry.value;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${intervalo['inicio']} - ${intervalo['fim']}',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    _horariosPorDia[dia]!.removeAt(index);
                                  });

                                  // Exibe o SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Intervalo removido com sucesso.',
                                      ),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar conta'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: 'Endereço'),
              ),
              DropdownButtonFormField<String>(
                value: _generoSelecionado,
                items: const [
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _generoSelecionado = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Selecione um gênero'
                    : null,
              ),
              SizedBox(height: 24),
              SizedBox(height: 24),
              Text('Defina horários por dia:'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _horariosPorDia.keys.map((dia) {
                  return ElevatedButton(
                    onPressed: () => _abrirHorarioDialog(dia),
                    child: Text(dia),
                  );
                }).toList(),
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
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _criarConta,
                      child: Text('Entrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
