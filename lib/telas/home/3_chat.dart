import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapia_mais_4terapeutas/telas/chat/troca_mensagens.dart';

class TelaEscolhaChat extends StatefulWidget {
  const TelaEscolhaChat({super.key});

  @override
  State<TelaEscolhaChat> createState() => _TelaEscolhaChatState();
}

class _TelaEscolhaChatState extends State<TelaEscolhaChat> {
  // Converte uma string que pode ser data URI, base64 puro ou URL para ImageProvider.
  ImageProvider? _imageProviderFromString(String? foto) {
    if (foto == null || foto.isEmpty) return null;

    try {
      if (foto.startsWith('data:image')) {
        final parts = foto.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          return MemoryImage(bytes);
        }
      }

      // se parece com URL, usa NetworkImage
      if (foto.startsWith('http') || foto.startsWith('https')) {
        return NetworkImage(foto);
      }

      // tenta decodificar como base64 puro
      try {
        final bytes = base64Decode(foto);
        return MemoryImage(bytes);
      } catch (_) {
        // fallback para NetworkImage (pode falhar se não for URL)
        return NetworkImage(foto);
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = authSnapshot.data;
          if (currentUser == null) {
            return const Center(child: Text('Usuário não autenticado.'));
          }

          final uidTerapeuta = currentUser.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('usuarios', arrayContains: uidTerapeuta)
                .orderBy('criadoEm', descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chatSnapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar chats: ${chatSnapshot.error}'),
                );
              }

              final chats = chatSnapshot.data?.docs ?? [];
              if (chats.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum chat encontrado.\nOs chats aparecerão quando forem iniciados.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatData = chat.data() as Map<String, dynamic>;
                  final String chatId = chat.id;
                  final List usuarios = chatData['usuarios'] ?? [];

                  // Encontrar outro UID
                  final outroUid = usuarios.firstWhere(
                    (u) => u != uidTerapeuta,
                    orElse: () => null,
                  );

                  if (outroUid == null) {
                    return const SizedBox();
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(outroUid)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      String nomeOutroUsuario = 'Usuário';
                      String fotoOutroUsuario = '';

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final data =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        nomeOutroUsuario = data['nome'] ?? 'Usuário';
                        fotoOutroUsuario = data.containsKey('foto') &&
                                data['foto'] != null &&
                                data['foto'].toString().isNotEmpty
                            ? data['foto'].toString()
                            : '';
                      }

                      final ImageProvider? avatarImage =
                          _imageProviderFromString(fotoOutroUsuario);

                      final String ultimaMensagem =
                          (chatData['ultimaMensagem'] as String?) ??
                              'Toque para abrir a conversa';
                      final String status = (chatData['status'] as String?) ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaChatUnificada(
                                  chatId: chatId,
                                  nomeOutroUsuario: nomeOutroUsuario,
                                  fotoOutroUsuario: fotoOutroUsuario,
                                  uidOutroUsuario: outroUid,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 92,
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: avatarImage,
                                  child: avatarImage == null
                                      ? Text(
                                          nomeOutroUsuario
                                              .split(' ')
                                              .map((s) =>
                                                  s.isNotEmpty ? s[0] : '')
                                              .take(2)
                                              .join()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nomeOutroUsuario,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ultimaMensagem,
                                        style: TextStyle(
                                            color: Colors.grey.shade600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 12.0, left: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: status == 'ativo'
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Icon(Icons.chevron_right,
                                          color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
