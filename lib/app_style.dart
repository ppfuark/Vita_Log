import 'package:flutter/material.dart';

class AppStyle {
  AppStyle._();

  static TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppStyle.tS,
  );
  static TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppStyle.tP,
  );
  static TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppStyle.tP,
  );
  static TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppStyle.tS,
  );

  static Color primary = Color.fromARGB(255, 113, 11, 180);
  static Color tP = Color(0xff1a1a2e);
  static Color tS = Color(0xff4a4a6a);
  static Color alert = Color(0xffe63946);
  static Color sucess = Color(0xff2d9e6b);
  static Color error = Color(0xffc0392b);
}
