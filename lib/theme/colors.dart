
import 'package:flutter/material.dart';

class ThemeColors{
 // PRIMARY COLORS
  static const Color deepestTeal =
      Color.fromARGB(255, 5, 25, 30);

  static const Color darkTeal =
      Color.fromARGB(255, 8, 55, 62);

  static const Color primaryTeal =
      Color.fromARGB(255, 15, 110, 120);

  static const Color secondaryTeal =
      Color.fromARGB(255, 55, 160, 165);

  static const Color accentCyan =
      Color.fromARGB(255, 55, 180, 190);

  static const Color lightCyan =
      Color.fromARGB(255, 190, 235, 238);

 // BACKGROUND COLORS
  static const Color background =Color.fromARGB(255, 2, 27, 31);
      //Color.fromARGB(255, 244, 249, 249);

  static const Color backgroundLight =
      Color.fromARGB(255, 235, 245, 246);

  static const Color card =
      Color.fromARGB(255, 255, 255, 255);


// TEXT COLORS
  static const Color textPrimary =
      Color.fromARGB(255, 30, 81, 88);

  static const Color textSecondary =
      Color.fromARGB(255, 95, 115, 118);

  static const Color textLight =
      Color.fromARGB(255, 188, 222, 222);

  static const Color textMuted =
      Color.fromARGB(255, 145, 160, 162);

  // STATUS COLORS
  static const Color success =
      Color.fromARGB(255, 55, 145, 105);

  static const Color warning =
      Color.fromARGB(255, 220, 165, 70);

  static const Color error =
      Color.fromARGB(255, 205, 75, 75);

  static const Color info =
      Color.fromARGB(255, 70, 140, 190);

  // BORDER / DIVIDER
  static const Color border =
      Color.fromARGB(255, 215, 228, 229);

  static const Color divider =
      Color.fromARGB(255, 225, 235, 235);

  // GRADIENT
  static const LinearGradient primaryGradient =
      LinearGradient(
    colors: [
      deepestTeal,
      darkTeal,
      primaryTeal,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // SOFT GRADIENT
static const LinearGradient softGradient =
      LinearGradient(
    colors: [
      Color.fromARGB(255, 8, 55, 62),
      Color.fromARGB(255, 55, 160, 165),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}