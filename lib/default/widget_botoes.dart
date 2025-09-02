import 'package:flutter/material.dart';

ButtonStyle estiloBotao() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

InputDecoration estiloCaixaTexto(String dica) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: dica,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  );
}