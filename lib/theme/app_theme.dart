import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A6CF1);
  static const Color primaryDark = Color(0xFF084FBB);
  static const Color background = Color(0xFFF5F7FA);
  static const Color primaryBlue = Color(0xFF0A6CF1);
  static const Color darkBlue = Color(0xFF084FBB);
  static const Color lightBlue = Color(0xFFE9F3FF);

  static const Color textDark = Color(0xFF1B1E28);
  static const Color textLight = Color(0xFF6F7A8A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,
    fontFamily: "IRANYekan",

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: textDark,
    ),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: textLight,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(primaryBlue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  );
}
