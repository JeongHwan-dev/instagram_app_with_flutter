import 'package:flutter/material.dart';

var theme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontSize: 25,
      color: Colors.black,
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.grey,
    ),
  ),
  textTheme: TextTheme(
    bodyText2: TextStyle(
      color: Colors.black,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
  ),
);
