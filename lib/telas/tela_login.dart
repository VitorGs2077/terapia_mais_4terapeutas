import 'package:flutter/material.dart';
import 'package:terapia_mais_4terapeutas/default/colors.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';
import 'package:terapia_mais_4terapeutas/default/widget_botoes.dart';
import 'package:terapia_mais_4terapeutas/telas/home.dart';

Widget botao(void Funcao(), String texto) {
  return ElevatedButton(
    style: estiloBotao(),
    onPressed: () {
      Funcao();
    },
    child: Text(texto),
  );
}
Widget caixaTexto(String dica) {
  return TextField(
    decoration: estiloCaixaTexto(dica),
  );
}

class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [azul, verde],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100),
              Image.asset('images/logo_light.png'),
              SizedBox(height: 20),
              caixaTexto("Email"),
              SizedBox(height: 20),
              caixaTexto("Senha"),
              SizedBox(height: 20),
              botao(irPara(context, telaHome()), 'Tela home'),
            ],
          ),
        ),
      ),
    );
  }
}
