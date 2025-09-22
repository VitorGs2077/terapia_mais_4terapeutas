import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class telaVisualizacaoGeral extends StatefulWidget {
  const telaVisualizacaoGeral({super.key});

  @override
  State<telaVisualizacaoGeral> createState() => telaVisualizacaoGeralState();
}

class telaVisualizacaoGeralState extends State<telaVisualizacaoGeral> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _eventoController = TextEditingController();
  List<String> _eventos = [];

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('eventos')
        .where(
          'data',
          isEqualTo: _selectedDay.toIso8601String().substring(0, 10),
        )
        .get();

    setState(() {
      _eventos = snapshot.docs
          .map((doc) => doc['descricao'] as String)
          .toList();
    });
  }

  Future<void> _salvarEvento() async {
    if (_eventoController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('eventos').add({
      'data': _selectedDay.toIso8601String().substring(0, 10),
      'descricao': _eventoController.text,
    });
    _eventoController.clear();
    _carregarEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TableCalendar(
              focusedDay: _selectedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
                _carregarEventos();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _eventoController,
                decoration: InputDecoration(
                  labelText: 'Novo evento',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _salvarEvento,
              child: Text('Salvar evento'),
            ),
            SizedBox(height: 16),
            Text(
              'Eventos do dia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._eventos.map((evento) => ListTile(title: Text(evento))).toList(),
          ],
        ),
      ),
    );
  }
}
