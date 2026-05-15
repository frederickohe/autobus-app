import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual baseline for hub screens opened from Home (matches [ManageChats]).
class ManageScreenStyle {
  ManageScreenStyle._();

  static const Color backgroundStart = Color(0xFF160A2C);
  static const Color backgroundEnd = Color(0xFF0C0418);
  static const Color headerRingBorder = Color.fromRGBO(255, 255, 255, 0.15);

  /// Same vertical gradient as the [Home] dashboard background.
  static const BoxDecoration homeDashboardBodyDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130522), Color(0xFF000000)],
    ),
  );

  static BoxDecoration bodyGradientDecoration() => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backgroundStart, backgroundEnd],
    ),
  );

  static TextStyle headerTitleStyle() => GoogleFonts.inter(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.2,
  );
}

class ManageScreenBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ManageScreenBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ManageScreenStyle.headerRingBorder),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
