import 'package:autobus/barrel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageOutlets extends StatelessWidget {
  const ManageOutlets({super.key});

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
                          'Link Outlet',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Linked Outlets',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 133 / 89,
                    children: const [
                      _OutletCard(
                        label: 'LinkedIn',
                        icon: FaIcon(FontAwesomeIcons.linkedinIn),
                        iconColor: Color(0xFF0A66C2),
                      ),
                      _OutletCard(
                        label: 'Facebook',
                        icon: FaIcon(FontAwesomeIcons.facebookF),
                        iconColor: Color(0xFF1877F2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Select to Link Outlet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 133 / 89,
                      children: const [
                        _OutletCard(
                          label: 'WhatsApp Status',
                          icon: FaIcon(FontAwesomeIcons.whatsapp),
                          iconColor: Color(0xFF25D366),
                        ),
                        _OutletCard(
                          label: 'Instagram',
                          icon: FaIcon(FontAwesomeIcons.instagram),
                          iconColor: Color(0xFFDD2A7B),
                        ),
                        _OutletCard(
                          label: 'X',
                          icon: FaIcon(FontAwesomeIcons.xTwitter),
                          iconColor: Colors.white,
                        ),
                        _OutletCard(
                          label: 'Website',
                          icon: FaIcon(FontAwesomeIcons.globe),
                          iconColor: Color(0xFF94A3B8),
                        ),
                      ],
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

class _OutletCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color iconColor;

  const _OutletCard({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1333).withValues(alpha: 0.35),
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
