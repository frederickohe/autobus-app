import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared tokens for the light Figma shell used across hub and detail screens.
class LightScreenTheme {
  LightScreenTheme._();

  static const background = Color(0xFFF3F3F7);
  static const surface = Color(0xFFF8FAFC);
  static const accent = Color(0xFF7F03B9);
  static const button = Color(0xFF2D0C51);
  static const title = Colors.black;
  static const border = Color(0xFFE2E8F0);
  static const muted = Color(0xFF64748B);
  static const body = Color(0xFF4D4D4D);
  static const hint = Color(0xFFC1BCBC);
  static const field = Color(0xFFFAFAFA);
  static const warning = Color(0xFFE27C00);

  static TextStyle hubTitle(double scale) => GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 16 * scale.clamp(0.9, 1.05),
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle hubBody(double scale) => GoogleFonts.montserrat(
        color: body,
        fontSize: 13 * scale.clamp(0.9, 1.05),
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle listTitle(double scale) => GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 14 * scale.clamp(0.9, 1.05),
        fontWeight: FontWeight.w600,
      );

  static TextStyle listSubtitle(double scale) => GoogleFonts.montserrat(
        color: muted,
        fontSize: 12 * scale.clamp(0.9, 1.05),
        fontWeight: FontWeight.w400,
      );

  static TextStyle emptyState(double scale) => GoogleFonts.montserrat(
        color: body,
        fontSize: 14 * scale.clamp(0.9, 1.05),
        fontWeight: FontWeight.w400,
      );
}
