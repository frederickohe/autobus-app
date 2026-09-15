import 'package:autobus/icons/home_figma_icons.dart';
import 'package:flutter/material.dart';

/// Purple-outlined AI sparkle from the HOME header and FAB.
class AiSparkleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AiSparkleIcon({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF7F03B9),
  });

  @override
  Widget build(BuildContext context) {
    return HomeSfIcon(
      icon: HomeFigmaIcons.ai,
      size: size,
      color: color,
      fontWeight: FontWeight.w500,
    );
  }
}
