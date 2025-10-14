import 'package:flutter/material.dart';
import 'package:terapia_mais_4terapeutas/default/background_gradient.dart';
import 'package:terapia_mais_4terapeutas/default/variaveis.dart';
import 'package:terapia_mais_4terapeutas/telas/home/2_sessoes.dart';
import 'package:terapia_mais_4terapeutas/telas/home/3_chat.dart';
import 'package:terapia_mais_4terapeutas/telas/home/4_configuracoes.dart';
import '1_geral.dart';

class telaHome extends StatefulWidget {
  const telaHome({super.key});

  @override
  State<telaHome> createState() => _telaHomeState();
}

class _telaHomeState extends State<telaHome> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    telaVisualizacaoGeral(),
    TelaSessoesMarcadas(),
    TelaEscolhaChat(),
    TelaConfiguracoes(),
  ];

  // Lista de títulos para o AppBar
  final List<String> _titles = ['Home', 'Sessões', 'Chat', 'Configurações'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_selectedIndex]),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [azul, verde],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor:
            Colors.transparent, // Para o gradiente aparecer corretamente
      ),
      body: BackgroundGradient(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [azul, verde],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors
              .transparent, // mantém a transparência para mostrar o gradiente
          elevation: 0, // remove a sombra
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Sessões',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configurações',
            ),
          ],
        ),
      ),
    );
  }
}
