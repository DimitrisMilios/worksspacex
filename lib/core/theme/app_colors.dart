import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A090D);
  static const surface = Color(0xFF18151F);
  static const border = Color(0xFF2D2838);
  static const primary = Color(0xFFFF6B35); // Vibrant Orange
  static const secondary = Color(0xFFB5179E); // Neon Magenta
  static const accent = Color(0xFFF7A23B); // Honey Gold
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9E9AA7);

  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
