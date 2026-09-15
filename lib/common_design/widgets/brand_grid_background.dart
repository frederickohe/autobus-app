import 'package:flutter/material.dart';

enum BrandGridVariant { onboarding, signIn }

/// Purple dash grid used on onboarding and auth screens.
class BrandGridBackground extends StatelessWidget {
  final double scale;
  final Color gridColor;
  final Color? fadeToColor;
  final double height;
  final BrandGridVariant variant;

  const BrandGridBackground({
    super.key,
    required this.scale,
    this.gridColor = const Color(0xFF7F03B9),
    this.fadeToColor,
    this.height = 348,
    this.variant = BrandGridVariant.signIn,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height * scale),
      painter: BrandGridPainter(
        scale: scale,
        color: gridColor,
        fadeToColor: fadeToColor,
        variant: variant,
      ),
    );
  }
}

class BrandGridPainter extends CustomPainter {
  final double scale;
  final Color color;
  final Color? fadeToColor;
  final BrandGridVariant variant;

  const BrandGridPainter({
    required this.scale,
    required this.color,
    this.fadeToColor,
    this.variant = BrandGridVariant.signIn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 25.0;
    const columnSpacing = 80.0;

    void drawGrid({
      required double originX,
      required List<double> rowYs,
      required bool fade,
    }) {
      for (final rowY in rowYs) {
        for (var col = 0; col < 5; col++) {
          final x = originX + col * columnSpacing;
          if (rowY < 0 || rowY > size.height / scale) continue;

          final paint = Paint()
            ..strokeWidth = 0.5 * scale
            ..strokeCap = StrokeCap.round;

          if (fade && fadeToColor != null) {
            final t = (rowY / 318).clamp(0.0, 1.0);
            paint.color = Color.lerp(fadeToColor, color, t)!;
          } else {
            paint.color = color;
          }

          canvas.drawLine(
            Offset(x * scale, rowY * scale),
            Offset((x + dashWidth) * scale, rowY * scale),
            paint,
          );
        }
      }
    }

    if (variant == BrandGridVariant.onboarding) {
      drawGrid(
        originX: 56,
        rowYs: const [-2, 78, 158, 238, 318, 398, 478, 558],
        fade: false,
      );
      drawGrid(
        originX: 0,
        rowYs: const [18, 98, 178, 258, 338, 418, 498, 578],
        fade: false,
      );
      return;
    }

    drawGrid(
      originX: 57,
      rowYs: const [238, 318, 398, 478, 558],
      fade: false,
    );
    drawGrid(
      originX: 57,
      rowYs: const [-2, 78, 158, 238, 318],
      fade: fadeToColor != null,
    );
    drawGrid(
      originX: 0,
      rowYs: const [268, 348, 428, 508, 588],
      fade: false,
    );
    drawGrid(
      originX: 0,
      rowYs: const [28, 108, 188, 268, 348],
      fade: fadeToColor != null,
    );
  }

  @override
  bool shouldRepaint(covariant BrandGridPainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.color != color ||
      oldDelegate.fadeToColor != fadeToColor ||
      oldDelegate.variant != variant;
}
