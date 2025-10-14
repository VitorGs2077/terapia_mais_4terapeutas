import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class telaVisualizacaoGeral extends StatefulWidget {
  const telaVisualizacaoGeral({super.key});

  @override
  State<telaVisualizacaoGeral> createState() => telaVisualizacaoGeralState();
}

class telaVisualizacaoGeralState extends State<telaVisualizacaoGeral> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _eventoController = TextEditingController();
  List<String> _eventos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  @override
  void dispose() {
    _eventoController.dispose();
    super.dispose();
  }

  String dataFormatada(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _carregarEventos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('eventos')
          .where('data', isEqualTo: dataFormatada(_selectedDay))
          .get();

      if (!mounted) return;

      setState(() {
        _eventos = snapshot.docs
            .map((doc) => doc['descricao'] as String)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar eventos: $e');
    }
  }

  Future<void> _salvarEvento() async {
    if (_eventoController.text.isEmpty || !mounted) return;

    try {
      await FirebaseFirestore.instance.collection('eventos').add({
        'data': dataFormatada(_selectedDay),
        'descricao': _eventoController.text,
      });

      if (!mounted) return;

      _eventoController.clear();
      _carregarEventos();
    } catch (e) {
      if (!mounted) return;
      print('Erro ao salvar evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Container que cria efeito de plano flutuante
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // cor do calendário
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!mounted) return;

                  setState(() {
                    _selectedDay = selectedDay;
                  });
                  _carregarEventos();
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _eventoController,
                decoration: const InputDecoration(
                  labelText: 'Novo evento',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ), // 🔹 borda preta
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarEvento,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Salvar evento'),
            ),
            SizedBox(height: 16),
            Text(
              'Eventos do dia:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              ..._eventos
                  .map((evento) => ListTile(title: Text(evento)))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
