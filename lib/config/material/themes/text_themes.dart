import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyles {
  static final primaryHeaderStyle = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static final primaryHeaderStyle2 = GoogleFonts.play(
    color: MainColors.primaryTextColor,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static final primaryStyle = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    letterSpacing: 0.75,
  );
  static final primaryStyle2 = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    letterSpacing: 0.75,
  );
  static final messageStyle1 = GoogleFonts.montserratAlternates(
    color: MainColors.accentColor,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    letterSpacing: 0.75,
  );
  static final messageStyle2 = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    letterSpacing: 0.75,
  );
  static final messageStyle3 = GoogleFonts.montserratAlternates(
    color: MainColors.accentColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    letterSpacing: 0.75,
  );
  static final secondaryStyle = GoogleFonts.montserratAlternates(
    color: MainColors.secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final secondaryStyleOrange = GoogleFonts.montserratAlternates(
    color: MainColors.accentColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final secondaryStyleGreen = GoogleFonts.montserratAlternates(
    color: Colors.green,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final secondaryStyleRed = GoogleFonts.montserratAlternates(
    color: Colors.red,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final secondaryHeaderStyle = GoogleFonts.play(
    color: MainColors.secondaryTextColor,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static final primaryHeaderStyleLogin = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 48,
    fontWeight: FontWeight.w700,
  );
  static final secondaryStyleLogin1 = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static final secondaryStyleLogin2 = GoogleFonts.montserratAlternates(
    color: MainColors.primaryTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w200,
  );
}
