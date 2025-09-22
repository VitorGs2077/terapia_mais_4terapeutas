import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class telaEscolhaChat extends StatelessWidget {
  const telaEscolhaChat({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum chat encontrado',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        }
        // Lista de chats com verificação de campo
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nome = data.containsKey('nome') ? data['nome'] : 'Chat sem nome';
            return ListTile(
              title: Text(nome),
            );
          }).toList(),
        );
      },
    );
  }
}
