import 'dart:ui';

import 'package:autobus/barrel.dart';

enum _MarketingType { pictures, videos, text }

class DigitalMarketingSelection extends StatefulWidget {
  const DigitalMarketingSelection({super.key});

  @override
  State<DigitalMarketingSelection> createState() =>
      _DigitalMarketingSelectionState();
}

class _DigitalMarketingSelectionState extends State<DigitalMarketingSelection> {
  _MarketingType? _selected;

  static const _accent = Color(0xFF251446);

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

  void _onGetStarted() {
    if (_selected == null) {
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
        builder: (_) =>
            DigitalMarketingPage(initialSelected: {_mapType(_selected!)}),
      ),
    );
  }

  Widget _buildCard({
    required String label,
    required IconData icon,
    required _MarketingType type,
  }) {
    final selected = _selected == type;
    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 144,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED).withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFB794F6)
                : Colors.white.withValues(alpha: 0.14),
            width: selected ? 2.2 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    if (selected)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB794F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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
                children: [
                  const ManageScreenHeader(title: 'Digital Marketing'),
                  const SizedBox(height: 24),
                  Text(
                    'Select marketing content',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          children: [
                            _buildCard(
                              label: 'Pictures',
                              icon: Icons.photo_library_outlined,
                              type: _MarketingType.pictures,
                            ),
                            const SizedBox(height: 16),
                            _buildCard(
                              label: 'Videos',
                              icon: Icons.videocam_outlined,
                              type: _MarketingType.videos,
                            ),
                            const SizedBox(height: 16),
                            _buildCard(
                              label: 'Text',
                              icon: Icons.text_snippet_outlined,
                              type: _MarketingType.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          elevation: 6,
                          shadowColor: _accent.withValues(alpha: 0.25),
                        ),
                        onPressed: _onGetStarted,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get started',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 20,
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
