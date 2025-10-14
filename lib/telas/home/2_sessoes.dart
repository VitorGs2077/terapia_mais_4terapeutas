import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TelaSessoesMarcadas extends StatefulWidget {
  const TelaSessoesMarcadas({super.key});

  @override
  State<TelaSessoesMarcadas> createState() => _TelaSessoesMarcadasState();
}

class _TelaSessoesMarcadasState extends State<TelaSessoesMarcadas> {
  final uidTerapeuta = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _removerSessao(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover sessão'),
        content: const Text('Deseja remover esta sessão de terapia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('eventos').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão removida com sucesso')),
      );
    }
  }

  Future<String> _getNomePaciente(String uidPaciente) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uidPaciente).get();
    final data = doc.data();
    if (data == null) return 'Paciente desconhecido';
    return data['nome'] ?? 'Paciente sem nome';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // traz todos os eventos; separaremos em sessões (marcadas por paciente)
        // e eventos genéricos (criados pelo terapeuta na tela 1_geral)
        stream: FirebaseFirestore.instance
            .collection('eventos')
            .orderBy('data', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma sessão ou evento encontrado.'));
          }

          final docs = snapshot.data!.docs;
          // Sessões marcadas por pacientes: possuem uidTerapeuta igual ao terapeuta e têm uidPaciente
          final sessoes = docs.where((d) {
            final m = d.data() as Map<String, dynamic>;
            return m.containsKey('uidTerapeuta') &&
                m['uidTerapeuta'] == uidTerapeuta;
          }).toList();

          // Eventos criados pelo terapeuta (ou gerais): não têm uidPaciente e não são sessões de pacientes
          final eventosTerapeuta = docs.where((d) {
            final m = d.data() as Map<String, dynamic>;
            final hasUidTer = m.containsKey('uidTerapeuta') && (m['uidTerapeuta']?.toString().isNotEmpty ?? false);
            final hasUidPac = m.containsKey('uidPaciente') && (m['uidPaciente']?.toString().isNotEmpty ?? false);
            // identificar como evento terapeuta quando NÃO tiver uidPaciente
            return !hasUidPac && (!hasUidTer || m['uidTerapeuta'] == uidTerapeuta || m['uidTerapeuta'] == null);
          }).toList();

          final List<Widget> children = [];

          // Header sessões
          children.add(const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Sessões marcadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ));

          if (sessoes.isEmpty) {
            children.add(const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Nenhuma sessão marcada pelos pacientes.'),
            ));
          } else {
            for (final doc in sessoes) {
              final dataMap = doc.data() as Map<String, dynamic>;
              final dataString = dataMap['data'] ?? '';
              String diaFormatado = dataString;
              try {
                final dt = DateTime.parse(dataString);
                diaFormatado = DateFormat('dd/MM/yyyy').format(dt);
              } catch (_) {}
              final horario = dataMap['horario'] ?? 'Horário não informado';
              final uidPaciente = dataMap['uidPaciente'] ?? '';

              children.add(
                FutureBuilder<String>(
                  future: _getNomePaciente(uidPaciente),
                  builder: (context, nomeSnapshot) {
                    final nomePaciente = nomeSnapshot.data ?? 'Carregando...';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('$diaFormatado - $horario'),
                        subtitle: Text('Paciente: $nomePaciente'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removerSessao(doc.id),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }

          // Divider entre seções e eventos do terapeuta
          children.add(const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Divider(),
          ));
          children.add(const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Seus Eventos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ));

          if (eventosTerapeuta.isEmpty) {
            children.add(const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Nenhum evento criado.'),
            ));
          } else {
            for (final doc in eventosTerapeuta) {
              final dataMap = doc.data() as Map<String, dynamic>;
              final dataString = dataMap['data'] ?? '';
              String diaFormatado = dataString;
              try {
                final dt = DateTime.parse(dataString);
                diaFormatado = DateFormat('dd/MM/yyyy').format(dt);
              } catch (_) {}
              final descricao = dataMap['descricao'] ?? '';

              children.add(Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('$diaFormatado'),
                  subtitle: Text(descricao),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerSessao(doc.id),
                  ),
                ),
              ));
            }
          }

          return ListView(
            children: children,
          );
        },
      ),
    );
  }
}
