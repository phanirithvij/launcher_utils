import 'package:flutter/material.dart';

ThemeData buildAmoledTheme() {
  // reference : https://github.com/bimsina/wallpaper/blob/master/lib/bloc/utils.dart#L34
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    // Floating action theme is me just testing it
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      // Color.lerp(
      //   Colors.green.shade500,
      //   Colors.blue.shade500,
      //   .5,
      // ),
      foregroundColor: Colors.white,
    ),
    primaryColor: Colors.black,
    accentColor: Colors.white,
    canvasColor: Colors.transparent,
    primaryIconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline: TextStyle(
          fontFamily: 'Sans',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 24),
      body1: TextStyle(
          fontFamily: 'Sans',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 24),
      body2: TextStyle(
          fontFamily: 'Sans',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 18),
    ),
  );
}
