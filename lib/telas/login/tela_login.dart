import 'package:flutter/material.dart';
import 'package:terapia_mais_4terapeutas/default/background_gradient.dart';
import 'package:terapia_mais_4terapeutas/default/variaveis.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';
import 'package:terapia_mais_4terapeutas/default/widget_botoes.dart';
import 'package:terapia_mais_4terapeutas/telas/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapia_mais_4terapeutas/telas/login/teste.dart';

Future<void> enviarEmailTrocaSenha(BuildContext context, String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Email de redefinição enviado!')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
  }
}

Future<void> autenticarUsuario(
  BuildContext context,
  String email,
  String senha,
) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    // Login bem-sucedido, navegue para a tela principal
    irPara(context, telaHome())();
  } catch (e) {
    // Mostre erro para o usuário
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Email ou senha inválidos')));
  }
}

Widget botao(void Funcao(), String texto) {
  return ElevatedButton(
    style: estiloBotao(),
    onPressed: () {
      Funcao();
    },
    child: Text(style: TextStyle(fontWeight: FontWeight.bold), texto),
  );
}

Widget caixaTexto(String dica, controle, {bool senha = false}) {
  return TextField(
    controller: controle,
    decoration: estiloCaixaTexto(dica),
    obscureText: senha,
  );
}

final passwordController = TextEditingController();
final emailController = TextEditingController();

double widthTexto = 1.6;

class Telalogin extends StatelessWidget {
  const Telalogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradient(
        child: Center(
          child: ListView(
            //shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 24),
            children: [
              SizedBox(height: heightTela(context) / 5),

              Container(
                width: widthTela(context) / 1.2,
                child: Image.asset('images/logo_light.png'),
              ),
              SizedBox(height: heightTela(context) / 10),

              Container(
                width: widthTela(context) / widthTexto,
                child: caixaTexto("Email", emailController),
              ),
              SizedBox(height: 20),

              Container(
                width: widthTela(context) / widthTexto,
                child: caixaTexto("Senha", passwordController, senha: true),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Esqueceu sua senha?"),
                  TextButton(
                    onPressed: () {
                      enviarEmailTrocaSenha(context, emailController.text);
                    },
                    child: Text("Clique aqui!"),
                  ),
                ],
              ),

              SizedBox(height: 60),

              Container(
                child: botao(() {
                  autenticarUsuario(
                    context,
                    emailController.text,
                    passwordController.text,
                  );
                }, 'Login'),
              ),
              botao(irPara(context, LoginTeste()), 'criar conta')
            ],
          ),
        ),
      ),
    );
  }
}
