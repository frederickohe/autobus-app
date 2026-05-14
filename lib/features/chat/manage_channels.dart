import 'package:autobus/barrel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageChannels extends StatelessWidget {
  const ManageChannels({super.key});

  static const Color _backgroundStart = Color(0xFFFFFFFF);
  static const Color _backgroundEnd = Color(0xFFFFFFFF);
  static const Color _headerColor = Color(0xFF2A1447);
  static const Color _cardBorder = Color(0xFF2A1447);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundStart, _backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 428),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _headerColor,
                              border: Border.all(color: Colors.white, width: 0.5),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          'Manage Channels',
                          style: GoogleFonts.inter(
                            color: _headerColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 96),
                    Center(
                      child: Text(
                        'Linked Channels',
                        style: GoogleFonts.inter(
                          color: _headerColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 92),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 312),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 46,
                          mainAxisSpacing: 50,
                          childAspectRatio: 133 / 89,
                          children: [
                            _ChannelCard(
                              label: 'LinkedIn',
                              icon: const FaIcon(FontAwesomeIcons.linkedinIn),
                              iconColor: Color(0xFF0A66C2),
                            ),
                            _ChannelCard(
                              label: 'Facebook',
                              icon: const FaIcon(FontAwesomeIcons.facebookF),
                              iconColor: Color(0xFF0B5B9B),
                            ),
                            _ChannelCard(
                              label: 'WhatsApp Status',
                              icon: const FaIcon(FontAwesomeIcons.whatsapp),
                              iconColor: Color(0xFF25D366),
                            ),
                            _ChannelCard(
                              label: 'X',
                              icon: const FaIcon(FontAwesomeIcons.xTwitter),
                              iconColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Center(
                      child: Text(
                        'Select to Link Channel',
                        style: GoogleFonts.inter(
                          color: _headerColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color iconColor;

  const _ChannelCard({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2A1447), width: 0.3),
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 51,
              height: 51,
              child: ColoredBox(
                color: Colors.transparent,
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(color: iconColor, size: 42),
                    child: icon,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 6,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF0B5B9B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
