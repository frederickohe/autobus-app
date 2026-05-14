import 'dart:ui';

import 'package:autobus/barrel.dart';

enum _MarketingType { pictures, videos, text }

class DigitalMarketingSelection extends StatefulWidget {
  const DigitalMarketingSelection({super.key});

  @override
  State<DigitalMarketingSelection> createState() => _DigitalMarketingSelectionState();
}

class _DigitalMarketingSelectionState extends State<DigitalMarketingSelection> {
  _MarketingType? _selected;

  static const _accent = Color(0xFF251446);
  static const _bg = Color(0xFFF8F9FA);

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
        const SnackBar(content: Text('Please select a content type')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalMarketingPage(
          initialSelected: {_mapType(_selected!)},
        ),
      ),
    );
  }

  Widget _buildCard({required String label, required String imageUrl, required _MarketingType type}) {
    final selected = _selected == type;
    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 192,
        height: 144,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.92 : 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _accent : const Color.fromRGBO(30, 20, 60, 0.15),
            width: selected ? 2.2 : 1.0,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
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
                Text(label, style: GoogleFonts.inter(color: const Color(0xFF251446), fontWeight: FontWeight.w700)),
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Text('Digital Marketing', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1E143C))),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: _accent, width: 2), color: Colors.white),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: ClipOval(
                          child: Container(color: const Color(0xFFD32F2F)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Select Marketing Content', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF1E143C))),
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCard(
                        label: 'Pictures',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJuntLu18cAc3YTaBjYVzQtwseg2Pw5IvujZsRcYjyuuZhyhAn2cwCMRn4sFljwluyyYmis4-YY7R9IjnNdpiBLTs0ZZ3m3D7f6QSmOvJF4Q7nRc5lBNTFpOQlhZ8wHgSvh-R6Psl7IMmKzrPECdGdAtfZkI0YGhtdfiKXHrT4aooDwzxUfgvrdgQvsH8hflIq8pH2UWVGlF86XbfEaXH3ymK2EfG9v3uiICvThLmCnRlO4n_x5Cmi9vPyQyYRUrFRXEreDQ9fqIni',
                        type: _MarketingType.pictures,
                      ),
                      const SizedBox(height: 20),
                      _buildCard(
                        label: 'Videos',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1T3Jc4uswvVdP3dJ4Ty_F-CNw2xn13U-sEnV3yIctHlXPkENbBBV96EHbFn98vD9xFMnLN3o8EWRkn5Lnq_Y5TmRw0SWM4xc_8CjzxY_hEqACGr_qeOfV1JfclAUyv3RWQu6_L4GyjFzrcE_cOnMeX38LqxkQ_cGJyK-B9bcnHnL2J-h6luhlENnrH0yI-8HLST586-k09J63xb96dW_YG775zT0CliEVkRm2V1ToXd7klSt2PNzzCrxPMZXwYL18sSKVCK1y6fUD',
                        type: _MarketingType.videos,
                      ),
                      const SizedBox(height: 20),
                      _buildCard(
                        label: 'Text',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD-IxBa4Oxi9LsiL9UTMwJ2SFE2yCdvWBBS7oyPRu1qlhpRZFAMKYtRjOU2XWRFhUT1j4GtnI9hw0KGwF5TctA9MGSaRx5i5zW-nNL6zNXEbzXdLVDDHogzQzfSVjGi4KynFy-CdjconJyyBiZ9UhU0KlH8u0IxTETYe3HgGK5BRM5BSRe1Zk97QjaM4GI0E2670AqcJS7sw_MzkkVXHserypZoJsph53tVMzfXuRwLWkTuO9XIexZlXNeZzB68F7aCOSkVLHH9N_cq',
                        type: _MarketingType.text,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      elevation: 10,
                      shadowColor: _accent.withOpacity(0.25),
                    ),
                    onPressed: _onGetStarted,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.4), size: 18),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.7), size: 18),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
