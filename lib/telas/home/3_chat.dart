import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';

class telaEscolhaChat extends StatefulWidget {
  const telaEscolhaChat({super.key});

  @override
  State<telaEscolhaChat> createState() => _telaEscolhaChatState();
}

class _telaEscolhaChatState extends State<telaEscolhaChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum chat encontrado.'));
          } 
          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final terapeuta = chat['terapeuta'] ?? 'Terapeuta';
              final usuario = chat['usuario'] ?? 'Usuário';
              return ListTile(
                title: Text('$terapeuta - $usuario'),
                subtitle: Text('ID do chat: ${chat.id}'),
                onTap: () {
                  irPara(context, Placeholder());
                },
              );
            },
          );
        },
      ),
    );
  }
}
