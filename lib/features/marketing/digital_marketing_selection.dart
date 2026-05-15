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
        builder: (_) => DigitalMarketingPage(
          initialSelected: {_mapType(_selected!)},
        ),
      ),
    );
  }

  Widget _buildCard({
    required String label,
    required String imageUrl,
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
          color: Colors.white.withValues(alpha: selected ? 0.92 : 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _accent
                : const Color.fromRGBO(30, 20, 60, 0.15),
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
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF251446),
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
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Digital Marketing',
                          textAlign: TextAlign.center,
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
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
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCJuntLu18cAc3YTaBjYVzQtwseg2Pw5IvujZsRcYjyuuZhyhAn2cwCMRn4sFljwluyyYmis4-YY7R9IjnNdpiBLTs0ZZ3m3D7f6QSmOvJF4Q7nRc5lBNTFpOQlhZ8wHgSvh-R6Psl7IMmKzrPECdGdAtfZkI0YGhtdfiKXHrT4aooDwzxUfgvrdgQvsH8hflIq8pH2UWVGlF86XbfEaXH3ymK2EfG9v3uiICvThLmCnRlO4n_x5Cmi9vPyQyYRUrFRXEreDQ9fqIni',
                              type: _MarketingType.pictures,
                            ),
                            const SizedBox(height: 16),
                            _buildCard(
                              label: 'Videos',
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB1T3Jc4uswvVdP3dJ4Ty_F-CNw2xn13U-sEnV3yIctHlXPkENbBBV96EHbFn98vD9xFMnLN3o8EWRkn5Lnq_Y5TmRw0SWM4xc_8CjzxY_hEqACGr_qeOfV1JfclAUyv3RWQu6_L4GyjFzrcE_cOnMeX38LqxkQ_cGJyK-B9bcnHnL2J-h6luhlENnrH0yI-8HLST586-k09J63xb96dW_YG775zT0CliEVkRm2V1ToXd7klSt2PNzzCrxPMZXwYL18sSKVCK1y6fUD',
                              type: _MarketingType.videos,
                            ),
                            const SizedBox(height: 16),
                            _buildCard(
                              label: 'Text',
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD-IxBa4Oxi9LsiL9UTMwJ2SFE2yCdvWBBS7oyPRu1qlhpRZFAMKYtRjOU2XWRFhUT1j4GtnI9hw0KGwF5TctA9MGSaRx5i5zW-nNL6zNXEbzXdLVDDHogzQzfSVjGi4KynFy-CdjconJyyBiZ9UhU0KlH8u0IxTETYe3HgGK5BRM5BSRe1Zk97QjaM4GI0E2670AqcJS7sw_MzkkVXHserypZoJsph53tVMzfXuRwLWkTuO9XIexZlXNeZzB68F7aCOSkVLHH9N_cq',
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
