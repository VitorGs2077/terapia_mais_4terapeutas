import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:terapia_mais_4terapeutas/default/variaveis.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();

  String? _generoSelecionado;

  Map<String, List<Map<String, String>>> _horariosPorDia = {
    'Segunda': [],
    'Terça': [],
    'Quarta': [],
    'Quinta': [],
    'Sexta': [],
    'Sábado': [],
    'Domingo': [],
  };

  File? _imagemSelecionada; // Mobile
  Uint8List? _imagemSelecionadaWeb; // Web
  String? _fotoBase64;
  final _picker = ImagePicker();
  bool _loading = false;

  User? get _usuarioAtual => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _selecionarFoto() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imagemSelecionadaWeb = result.files.single.bytes!;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imagemSelecionada = File(pickedFile.path);
        });
      }
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
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (inicio != null && fim != null) {
                          setState(() {
                            _horariosPorDia[dia]!.add({
                              'inicio': inicio!.format(context),
                              'fim': fim!.format(context),
                            });
                          });
                          setDialogState(() {
                            inicio = null;
                            fim = null;
                          });
                        }
                      },
                      child: const Text('Adicionar intervalo'),
                    ),
                    const SizedBox(height: 16),
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
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _horariosPorDia[dia]!.removeAt(index);
                                  });
                                  Navigator.of(
                                    context,
                                  ).pop(); // Fecha o dialog após deletar
                                  _abrirHorarioDialog(
                                    dia,
                                  ); // Reabre pra atualizar visual
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
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _carregarDadosUsuario() async {
    if (_usuarioAtual == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_usuarioAtual!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nomeController.text = data['nome'] ?? '';
        _emailController.text = data['email'] ?? '';
        _descricaoController.text = data['descricao'] ?? '';
        _enderecoController.text = data['endereco'] ?? '';
        _numeroController.text = data['numero'] ?? '';
        _generoSelecionado = data['genero'] ?? '';
        _fotoBase64 = data['foto'];

        if (data['horarios'] != null) {
          final horarios = Map<String, dynamic>.from(data['horarios']);
          _horariosPorDia = horarios.map((dia, lista) {
            final converted = List<Map<String, String>>.from(
              (lista as List).map((item) => Map<String, String>.from(item)),
            );
            return MapEntry(dia, converted);
          });
        }
      });
    }
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      String? fotoString = _fotoBase64;

      if (_imagemSelecionadaWeb != null) {
        final compactada = _compactarImagem(_imagemSelecionadaWeb!);
        fotoString = base64Encode(compactada);
        _imagemSelecionadaWeb = null;
      } else if (_imagemSelecionada != null) {
        final bytes = await _imagemSelecionada!.readAsBytes();
        final compactada = _compactarImagem(bytes);
        fotoString = base64Encode(compactada);
        _imagemSelecionada = null;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_usuarioAtual!.uid)
          .set({
            'nome': _nomeController.text.trim(),
            'email': _emailController.text.trim(),
            'descricao': _descricaoController.text.trim(),
            'endereco': _enderecoController.text.trim(),
            'numero': _numeroController.text.trim(),
            'genero': _generoSelecionado ?? '',
            'foto': fotoString ?? '',
            'horarios': _horariosPorDia,
          }, SetOptions(merge: true));

      if (_usuarioAtual!.email != _emailController.text.trim()) {
        await _usuarioAtual!.verifyBeforeUpdateEmail(
          _emailController.text.trim(),
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar perfil: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Uint8List _compactarImagem(Uint8List bytes) {
    final image = img.decodeImage(bytes)!;
    final resized = img.copyResize(image, width: 600);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }

  Future<void> _trocarSenha() async {
    if (_usuarioAtual == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _usuarioAtual!.email!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de troca de senha enviado com sucesso!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  ImageProvider<Object>? _getImagemPerfil() {
    if (_imagemSelecionadaWeb != null) {
      return MemoryImage(_imagemSelecionadaWeb!);
    } else if (_imagemSelecionada != null) {
      return FileImage(_imagemSelecionada!) as ImageProvider;
    } else if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(_fotoBase64!));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selecionarFoto,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _getImagemPerfil(),
                        child: _getImagemPerfil() == null
                            ? const Icon(Icons.add_a_photo, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Digite seu nome'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Digite seu email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de Gênero
                    DropdownButtonFormField<String>(
                      value: _generoSelecionado != ''
                          ? _generoSelecionado
                          : null,
                      items: const [
                        DropdownMenuItem(
                          value: 'Feminino',
                          child: Text('Feminino'),
                        ),
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
                          _generoSelecionado = value!;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Selecione um gênero'
                          : null,
                    ),

                    const SizedBox(height: 24),
                    // Horários por dia
                    SizedBox(
                      width: widthTela(context),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Horários disponíveis por dia:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _horariosPorDia.keys.map((dia) {
                                  return ElevatedButton(
                                    onPressed: () => _abrirHorarioDialog(dia),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Text(dia),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _trocarSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Trocar senha'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _salvarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                      ),
                      child: const Text('Salvar alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
