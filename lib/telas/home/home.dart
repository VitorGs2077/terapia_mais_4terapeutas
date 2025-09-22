import 'package:flutter/material.dart';
import 'package:terapia_mais_4terapeutas/default/background_gradient.dart';
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
    Container(),
    telaEscolhaChat(),
    telaConfiguracoes(),
  ];

  // Lista de títulos para o AppBar
  final List<String> _titles = [
    'Agenda',
    'Home',
    'Chat',
    'Configurações',
  ];

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
      appBar: AppBar(title: Text(_titles[_selectedIndex])), // <-- Aqui muda o título dinamicamente
      body: BackgroundGradient(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
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
    );
  }
}