import 'package:autobus/barrel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageChannels extends StatelessWidget {
  const ManageChannels({super.key});

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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Manage Channels',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Linked Channels',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 28),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 133 / 89,
                            children: const [
                              _ChannelCard(
                                label: 'LinkedIn',
                                icon: FaIcon(FontAwesomeIcons.linkedinIn),
                                iconColor: Color(0xFF0A66C2),
                              ),
                              _ChannelCard(
                                label: 'Facebook',
                                icon: FaIcon(FontAwesomeIcons.facebookF),
                                iconColor: Color(0xFF1877F2),
                              ),
                              _ChannelCard(
                                label: 'WhatsApp Status',
                                icon: FaIcon(FontAwesomeIcons.whatsapp),
                                iconColor: Color(0xFF25D366),
                              ),
                              _ChannelCard(
                                label: 'X',
                                icon: FaIcon(FontAwesomeIcons.xTwitter),
                                iconColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),
                          Text(
                            'Select to Link Channel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3F1163)),
      ),
      child: Stack(
        children: [
          Center(
            child: IconTheme(
              data: IconThemeData(color: iconColor, size: 40),
              child: icon,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
