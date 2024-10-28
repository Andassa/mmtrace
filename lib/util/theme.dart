import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[850],
  scaffoldBackgroundColor: Colors.black, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyanAccent),
);
