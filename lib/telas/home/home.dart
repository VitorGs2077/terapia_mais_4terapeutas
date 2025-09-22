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
    Container(), // Substitui Placeholder por um widget transparente
    telaEscolhaChat(),
    telaConfiguracoes(),
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
  //teste
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
            label: 'Geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Tela 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tela 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Tela 4',
          ),
        ],
      ),
    );
  }
}