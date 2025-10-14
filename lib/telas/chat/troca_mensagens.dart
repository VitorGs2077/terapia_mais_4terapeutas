import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaChatUnificada extends StatefulWidget {
  final String chatId;
  final String uidOutroUsuario; // UID do outro usuário
  final String nomeOutroUsuario;
  final String fotoOutroUsuario;

  const TelaChatUnificada({
    super.key,
    required this.chatId,
    required this.uidOutroUsuario,
    required this.nomeOutroUsuario,
    required this.fotoOutroUsuario,
  });

  @override
  State<TelaChatUnificada> createState() => _TelaChatUnificadaState();
}

class _TelaChatUnificadaState extends State<TelaChatUnificada> {
  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? meuNome;
  String? minhaFoto;
  String? nomeOutroUsuarioReal;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final user = _auth.currentUser;
    
    if (user == null) return;

    // Dados do usuário logado
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      meuNome = data['nome'] ?? "Você";
      minhaFoto = data['foto'] ?? "";
    }

    // Dados do outro usuário
    final outroDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.uidOutroUsuario)
        .get();

    if (outroDoc.exists) {
      final outroData = outroDoc.data()!;
      setState(() {
        nomeOutroUsuarioReal = outroData['nome'] ?? widget.nomeOutroUsuario;
      });
    } else {
      setState(() {
        nomeOutroUsuarioReal = widget.nomeOutroUsuario;
      });
    }
  }

  void enviarMensagem() async {
    final texto = _mensagemController.text.trim();
    if (texto.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final mensagem = {
      "remetente": user.uid,
      "nome": meuNome ?? "Você",
      "foto": minhaFoto ?? "",
      "texto": texto,
      "enviadoEm": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('mensagens')
        .add(mensagem);

    _mensagemController.clear();

    // Scroll automático para baixo
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatarData(DateTime data) {
    return "${data.hour.toString().padLeft(2,'0')}:${data.minute.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(nomeOutroUsuarioReal ?? "Carregando..."),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(158, 19, 130, 155),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('mensagens')
                  .orderBy('enviadoEm', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final mensagens = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index].data() as Map<String, dynamic>;
                    final bool isMeuUsuario = msg['remetente'] == user?.uid;

                    return Align(
                      alignment: isMeuUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Material(
                          elevation: 6.0,
                          borderRadius: BorderRadius.circular(14),
                          color: isMeuUsuario ? Colors.white : Colors.grey[850],
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['nome'] ?? (isMeuUsuario ? "Você" : nomeOutroUsuarioReal ?? "Outro"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMeuUsuario ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg['texto'] ?? "",
                                    style: TextStyle(
                                      color: isMeuUsuario ? Colors.black87 : Colors.white,
                                    ),
                                  ),
                                  if (msg['enviadoEm'] != null)
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatarData((msg['enviadoEm'] as Timestamp).toDate()),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMeuUsuario ? Colors.black54 : Colors.white70,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                     );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensagemController,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => enviarMensagem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color.fromARGB(158, 19, 130, 155),
                  onPressed: enviarMensagem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
