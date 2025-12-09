import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData themes(ThemeMode themeMode, Color themeColor) {
  final brightness =
      themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  final textColor = brightness == Brightness.light
      ? AppColor.kGrayscaleDark100
      : AppColor.kWhite;

  return ThemeData(
    brightness: brightness,
    primaryColor: themeColor,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
    iconTheme: IconThemeData(color: textColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 85,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 25,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.dancingScript().fontFamily,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showUnselectedLabels: true,
      unselectedItemColor: textColor,
      unselectedLabelStyle: TextStyle(color: textColor),
      selectedLabelStyle: TextStyle(color: textColor),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      // backgroundColor: themeColor,
      shape: CircleBorder(),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor,
      brightness: brightness,
    ).copyWith(
      secondary: AppColor.kPurple,
    ),
  );
}
