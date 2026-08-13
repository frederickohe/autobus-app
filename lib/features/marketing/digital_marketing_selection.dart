import 'package:autobus/barrel.dart';

enum _MarketingType { pictures, videos, text }

class DigitalMarketingSelection extends StatefulWidget {
  const DigitalMarketingSelection({super.key});

  @override
  State<DigitalMarketingSelection> createState() =>
      _DigitalMarketingSelectionState();
}

class _DigitalMarketingSelectionState extends State<DigitalMarketingSelection> {
  final Set<_MarketingType> _selected = <_MarketingType>{};

  static const _green = Color(0xFF22C55E);

  MarketingContentType _mapType(_MarketingType type) {
    switch (type) {
      case _MarketingType.pictures:
        return MarketingContentType.pictures;
      case _MarketingType.videos:
        return MarketingContentType.videos;
      case _MarketingType.text:
        return MarketingContentType.text;
    }
  }

  void _toggle(_MarketingType type) {
    setState(() {
      if (_selected.contains(type)) {
        _selected.remove(type);
      } else {
        _selected.add(type);
      }
    });
  }

  void _onGetStarted() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a content type',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DigitalMarketingPage(
          initialSelected: _selected.map(_mapType).toSet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: ManageScreenStyle.homeDashboardBodyDecoration,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ManageScreenHeader(
                    title: 'Digital Marketing',
                    creditCategory: CreditCategory.imageGen,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'What are you creating?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap one or more. Selected items get a green outline.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          children: [
                            _ContentOptionRow(
                              label: 'Pictures',
                              hint: 'Stills & carousels',
                              icon: Icons.photo_library_outlined,
                              selected: _selected.contains(_MarketingType.pictures),
                              accent: _green,
                              onTap: () => _toggle(_MarketingType.pictures),
                            ),
                            const SizedBox(height: 10),
                            _ContentOptionRow(
                              label: 'Videos',
                              hint: 'Clips & reels',
                              icon: Icons.videocam_outlined,
                              selected: _selected.contains(_MarketingType.videos),
                              accent: _green,
                              onTap: () => _toggle(_MarketingType.videos),
                            ),
                            const SizedBox(height: 10),
                            _ContentOptionRow(
                              label: 'Text',
                              hint: 'Captions & copy',
                              icon: Icons.text_snippet_outlined,
                              selected: _selected.contains(_MarketingType.text),
                              accent: _green,
                              onTap: () => _toggle(_MarketingType.text),
                            ),
                            if (_selected.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final t in _MarketingType.values)
                                    if (_selected.contains(t))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _green.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _green.withValues(alpha: 0.55),
                                          ),
                                        ),
                                        child: Text(
                                          t == _MarketingType.pictures
                                              ? 'Pictures'
                                              : t == _MarketingType.videos
                                                  ? 'Videos'
                                                  : 'Text',
                                          style: GoogleFonts.montserrat(
                                            color: _green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustColors.mainCol,
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentOptionRow extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ContentOptionRow({
    required this.label,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? accent
                  : Colors.white.withValues(alpha: 0.14),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? accent : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1 : 0,
                child: Icon(Icons.check_circle_rounded, color: accent, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
