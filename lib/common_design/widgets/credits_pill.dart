import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/widgets/app_screen_header.dart';

/// Header credits badge — Figma `3240:3112` (Notification pill).
class CreditsPill extends StatefulWidget {
  final double scale;
  final String creditCategory;

  const CreditsPill({
    super.key,
    required this.scale,
    required this.creditCategory,
  });

  static const pillColor = Color(0xFFF8FAFC);
  static const textColor = Color(0xFF64748B);
  static const tokenColor = Color(0xFFEDAD09);

  @override
  State<CreditsPill> createState() => _CreditsPillState();
}

class _CreditsPillState extends State<CreditsPill> {
  double? _remaining;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ApiService>().getMyCredits();
      if (!mounted) return;
      final credits = data?['credits'];
      if (credits is Map) {
        final item = credits[widget.creditCategory];
        if (item is Map) {
          final rem = item['remaining'];
          setState(() {
            _remaining = rem is num
                ? rem.toDouble()
                : double.tryParse(rem?.toString() ?? '');
            _loading = false;
          });
          return;
        }
      }
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _displayValue() {
    if (_loading) return '…';
    if (_remaining == null) return '—';
    return '${_remaining!.round()} credits';
  }

  void _openSubscription() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: kManageSubscriptionRouteName),
        builder: (_) => const ManageSubscriptionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerScale = widget.scale.clamp(0.9, 1.0);
    final iconSize = 20 * headerScale;
    final pillHeight = 37 * headerScale;
    final maxWidth = AppScreenHeader.sideSlotWidthFor(widget.scale);

    return Material(
      color: CreditsPill.pillColor,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openSubscription,
        borderRadius: BorderRadius.circular(100),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: pillHeight,
            maxWidth: maxWidth,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              5 * headerScale,
              5 * headerScale,
              8 * headerScale,
              5 * headerScale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: CreditsTokenIcon(size: iconSize),
                ),
                SizedBox(width: 3 * headerScale),
                Flexible(
                  child: Text(
                    _displayValue(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: CreditsPill.textColor,
                      fontSize: 11.5 * headerScale,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlapping gold token coins with a foreground "C" — Figma `3240:3113`.
class CreditsTokenIcon extends StatelessWidget {
  final double size;

  const CreditsTokenIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CreditsTokenIconPainter(),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

class _CreditsTokenIconPainter extends CustomPainter {
  static const _gold = CreditsPill.tokenColor;
  static const _goldDark = Color(0xFFD89408);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = _gold
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = _goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    // Back coin — upper right, slightly larger (Figma vector 3240:3791).
    final backCenter = Offset(size.width * 0.60, size.height * 0.36);
    final backRadius = size.width * 0.30;
    canvas.save();
    canvas.translate(backCenter.dx, backCenter.dy);
    canvas.rotate(-0.08);
    canvas.drawCircle(Offset.zero, backRadius, fillPaint);
    canvas.drawCircle(Offset.zero, backRadius, rimPaint);
    canvas.restore();

    // Front coin — lower left with "C" (Figma vector 3240:3790).
    final frontCenter = Offset(size.width * 0.40, size.height * 0.62);
    final frontRadius = size.width * 0.26;
    canvas.drawCircle(frontCenter, frontRadius, fillPaint);
    canvas.drawCircle(frontCenter, frontRadius, rimPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'C',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.30,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      frontCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
