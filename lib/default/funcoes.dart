import 'package:flutter/material.dart';

VoidCallback irPara(BuildContext context, Widget tela, {bool apagarAnterior = false}) {
  return () {
    if (apagarAnterior) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => tela),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => tela),
      );
    }
  };
}