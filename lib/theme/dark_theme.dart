import 'package:flutter/material.dart';
import 'package:lestar_user/util/app_constants.dart';

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFe7913a),
  secondaryHeaderColor: const Color(0x9BFF7918),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF5E6472),
  cardColor: const Color(0xFF141313),
  shadowColor: Colors.white.withValues(alpha: 0.03),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFe7913a)),
  ),
  colorScheme:
      const ColorScheme.dark(
            primary: Color(0xFFe7913a),
            tertiary: Color(0xff6165D7),
            tertiaryContainer: Color(0xff171DB6),
            secondary: Color(0x9Be7913a),
          )
          .copyWith(surface: const Color(0xFF272727))
          .copyWith(error: const Color(0xFFdd3135)),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF29292D),
    surfaceTintColor: Color(0xFF29292D),
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: BottomAppBarThemeData(
    surfaceTintColor: Colors.black,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(
    color: const Color(0xffa2a7ad).withValues(alpha: 0.25),
    thickness: 0.5,
  ),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
