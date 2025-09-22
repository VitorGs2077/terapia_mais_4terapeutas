import 'package:flutter/material.dart';

ButtonStyle estiloBotao() {
  return ElevatedButton.styleFrom(
    side: BorderSide(color: Colors.black, width: 1),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

InputDecoration estiloCaixaTexto(String dica) {
  return InputDecoration(
    hintStyle: TextStyle(fontWeight: FontWeight.bold),
    filled: true,
    fillColor: Colors.white,
    hintText: dica,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  );
}
