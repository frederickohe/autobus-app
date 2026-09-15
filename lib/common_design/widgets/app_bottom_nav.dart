import 'package:autobus/common_design/widgets/ai_sparkle_icon.dart';
import 'package:autobus/icons/fluent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

enum AppNavTab { home, analytics }

/// Which main shell screen is active — drives nav icon colors only.
enum AppShellDestination { home, analytics, intelligence }

const appShellDesignWidth = 402.0;

/// Shared bottom navigation used across main app screens.
class AppBottomNav extends StatelessWidget {
  final AppShellDestination destination;
  final ValueChanged<AppNavTab>? onTabSelected;
  final VoidCallback? onCenterTap;

  const AppBottomNav({
    super.key,
    this.destination = AppShellDestination.home,
    this.onTabSelected,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = 80 * scale;
    final fabSize = 48 * scale.clamp(0.9, 1.1);
    final fabOverlap = fabSize * 0.46;

    return Padding(
      padding: EdgeInsets.fromLTRB(21 * scale, 0, 21 * scale, 8 * scale + bottomInset),
      child: SizedBox(
        height: barHeight + fabOverlap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(double.infinity, barHeight),
              painter: _NotchedNavBarPainter(
                topRadius: 24 * scale,
                bottomRadius: 24 * scale,
                fabRadius: fabSize / 2 + 4 * scale,
              ),
              child: Container(
                height: barHeight,
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavTabButton(
                        scale: scale,
                        label: 'Home',
                        active: destination == AppShellDestination.home,
                        onTap: () => onTabSelected?.call(AppNavTab.home),
                        icon: _HomeNavIcon(
                          active: destination == AppShellDestination.home,
                          size: 20 * scale.clamp(0.9, 1.1),
                        ),
                      ),
                    ),
                    SizedBox(width: fabSize + 12 * scale),
                    Expanded(
                      child: _NavTabButton(
                        scale: scale,
                        label: 'Analytics',
                        active: destination == AppShellDestination.analytics,
                        onTap: () => onTabSelected?.call(AppNavTab.analytics),
                        icon: _AnalyticsNavIcon(
                          active: destination == AppShellDestination.analytics,
                          size: 20 * scale.clamp(0.9, 1.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _CenterNavFab(
                size: fabSize,
                active: destination == AppShellDestination.intelligence,
                onTap: onCenterTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotchedNavBarPainter extends CustomPainter {
  final double topRadius;
  final double bottomRadius;
  final double fabRadius;

  const _NotchedNavBarPainter({
    required this.topRadius,
    required this.bottomRadius,
    required this.fabRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.10),
      10,
      false,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final notchHalfWidth = fabRadius + 6;
    final notchDepth = fabRadius * 0.88;

    return Path()
      ..moveTo(topRadius, 0)
      ..lineTo(cx - notchHalfWidth, 0)
      ..cubicTo(
        cx - notchHalfWidth * 0.55,
        0,
        cx - fabRadius * 0.85,
        notchDepth * 0.55,
        cx,
        notchDepth,
      )
      ..cubicTo(
        cx + fabRadius * 0.85,
        notchDepth * 0.55,
        cx + notchHalfWidth * 0.55,
        0,
        cx + notchHalfWidth,
        0,
      )
      ..lineTo(w - topRadius, 0)
      ..arcToPoint(
        Offset(w, topRadius),
        radius: Radius.circular(topRadius),
      )
      ..lineTo(w, h - bottomRadius)
      ..arcToPoint(
        Offset(w - bottomRadius, h),
        radius: Radius.circular(bottomRadius),
      )
      ..lineTo(bottomRadius, h)
      ..arcToPoint(
        Offset(0, h - bottomRadius),
        radius: Radius.circular(bottomRadius),
      )
      ..lineTo(0, topRadius)
      ..arcToPoint(
        Offset(topRadius, 0),
        radius: Radius.circular(topRadius),
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _NotchedNavBarPainter oldDelegate) {
    return oldDelegate.topRadius != topRadius ||
        oldDelegate.bottomRadius != bottomRadius ||
        oldDelegate.fabRadius != fabRadius;
  }
}

class _CenterNavFab extends StatelessWidget {
  final double size;
  final bool active;
  final VoidCallback? onTap;

  const _CenterNavFab({
    required this.size,
    this.active = false,
    this.onTap,
  });

  static const _accentColor = Color(0xFF7F03B9);
  static const _inactiveBrainColor = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? _accentColor : Colors.white,
      elevation: 10,
      shadowColor: const Color(0x40005D5D),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Iconify(
              Fluent.brain_circuit_20_regular,
              color: active ? Colors.white : _inactiveBrainColor,
              size: size * 0.46,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeNavIcon extends StatelessWidget {
  final bool active;
  final double size;

  const _HomeNavIcon({required this.active, required this.size});

  static const _activeColor = Color(0xFF6929C4);
  static const _inactiveColor = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HomeGlyphPainter(
          color: active ? _activeColor : _inactiveColor,
        ),
      ),
    );
  }
}

class _HomeGlyphPainter extends CustomPainter {
  final Color color;

  const _HomeGlyphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.92, h * 0.40)
      ..lineTo(w * 0.78, h * 0.92)
      ..lineTo(w * 0.22, h * 0.92)
      ..lineTo(w * 0.08, h * 0.40)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.10,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AnalyticsNavIcon extends StatelessWidget {
  final bool active;
  final double size;

  const _AnalyticsNavIcon({required this.active, required this.size});

  static const _activeColor = Color(0xFF6929C4);
  static const _inactiveColor = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnalyticsGlyphPainter(
          color: active ? _activeColor : _inactiveColor,
        ),
      ),
    );
  }
}

class _AnalyticsGlyphPainter extends CustomPainter {
  final Color color;

  const _AnalyticsGlyphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final inset = w * 0.08;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(rrect, paint);

    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    void bar(double x, double barH) {
      final width = w * 0.11;
      final left = w * x - width / 2;
      final top = h * 0.78 - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width, barH),
          Radius.circular(width / 2),
        ),
        barPaint,
      );
    }

    bar(0.34, h * 0.22);
    bar(0.50, h * 0.34);
    bar(0.66, h * 0.46);
  }

  @override
  bool shouldRepaint(covariant _AnalyticsGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _NavTabButton extends StatelessWidget {
  final double scale;
  final String label;
  final bool active;
  final Widget icon;
  final VoidCallback? onTap;

  const _NavTabButton({
    required this.scale,
    required this.label,
    required this.active,
    required this.icon,
    this.onTap,
  });

  static const _activeColor = Color(0xFF6929C4);
  static const _inactiveColor = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    final color = active ? _activeColor : _inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Padding(
        padding: EdgeInsets.only(top: 20 * scale, bottom: 10 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 4 * scale),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: color,
                fontSize: 12 * scale.clamp(0.85, 1.05),
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Purple floating AI button shown above the nav on main screens.
class AppAiAssistantFab extends StatelessWidget {
  final VoidCallback? onTap;

  const AppAiAssistantFab({super.key, this.onTap});

  static const _accentColor = Color(0xFF7F03B9);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;
    final size = 48 * scale.clamp(0.9, 1.1);

    return Material(
      color: _accentColor,
      elevation: 8,
      shadowColor: const Color(0x3D005D5D),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AiSparkleIcon(
              size: size * 0.62,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard shell for screens that share the bottom nav and AI FAB.
class AppShellScaffold extends StatelessWidget {
  final AppShellDestination destination;
  final Widget body;
  final Color backgroundColor;
  final bool showAiFab;
  final VoidCallback? onAiTap;
  final VoidCallback? onCenterNavTap;
  final ValueChanged<AppNavTab>? onTabSelected;

  const AppShellScaffold({
    super.key,
    this.destination = AppShellDestination.home,
    required this.body,
    this.backgroundColor = const Color(0xFFF3F3F7),
    this.showAiFab = true,
    this.onAiTap,
    this.onCenterNavTap,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final scale = MediaQuery.sizeOf(context).width / appShellDesignWidth;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          body,
          if (showAiFab)
            Positioned(
              right: 12 * scale,
              bottom: 96 * scale + bottomInset,
              child: AppAiAssistantFab(onTap: onAiTap),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              destination: destination,
              onTabSelected: onTabSelected,
              onCenterTap: onCenterNavTap,
            ),
          ),
        ],
      ),
    );
  }
}
