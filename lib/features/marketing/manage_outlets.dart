import 'package:autobus/barrel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageOutlets extends StatelessWidget {
  const ManageOutlets({super.key});

  static const _accent = Color(0xFF1A0B40);

  Widget _outletCard({required Widget icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF003B6D), fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Manage Outlets', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _accent)),
                ],
              ),
              const SizedBox(height: 18),
              Center(child: Text('Linked Outlets', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _accent))),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _outletCard(
                    icon: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Linked', style: GoogleFonts.inter(color: const Color(0xFF0077B5), fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      FaIcon(FontAwesomeIcons.linkedin, color: const Color(0xFF0077B5), size: 20),
                    ]),
                    label: 'LinkedIn',
                  ),
                  _outletCard(
                    icon: FaIcon(FontAwesomeIcons.facebook, color: const Color(0xFF1877F2), size: 36),
                    label: 'Facebook',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(child: Text('Select to Link Outlet', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _accent))),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _outletCard(
                      icon: FaIcon(FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366), size: 36),
                      label: 'WhatsApp Status',
                    ),
                    _outletCard(
                      icon: FaIcon(FontAwesomeIcons.instagram, color: const Color(0xFFDD2A7B), size: 36),
                      label: 'Instagram',
                    ),
                    _outletCard(
                      icon: FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 36),
                      label: 'X',
                    ),
                    _outletCard(
                      icon: FaIcon(FontAwesomeIcons.globe, color: Colors.black54, size: 36),
                      label: 'Website',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
