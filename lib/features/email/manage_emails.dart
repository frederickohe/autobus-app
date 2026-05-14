import 'package:autobus/barrel.dart';

class ManageEmails extends StatelessWidget {
  const ManageEmails({super.key});

  static const Color _backgroundStart = Color(0xFF130A2A);
  static const Color _backgroundEnd = Color(0xFF0D081B);
  static const Color _cardBorder = Color.fromRGBO(255, 255, 255, 0.1);
  static const Color _alertBorder = Color.fromRGBO(147, 51, 234, 0.4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundEnd,
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
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(32),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          'Manage Emails',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 56),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Emails',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Text(
                              'Send smart emails automatically for customer support, updates, promotions, and notifications.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 14,
                                height: 1.55,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    _AlertBanner(
                      borderColor: _alertBorder,
                      child: Row(
                        children: [
                          Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red.shade600, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '!',
                                style: GoogleFonts.inter(
                                  color: Colors.red.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'You not linked your sender address',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1,
                        children: [
                          _ActionCard(
                            borderColor: _cardBorder,
                            icon: Icons.send_outlined,
                            label: 'Send Mail',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Send Mail tapped')),
                              );
                            },
                          ),
                          _ActionCard(
                            borderColor: _cardBorder,
                            icon: Icons.mail_outline,
                            label: 'Sent Emails',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sent Emails tapped')),
                              );
                            },
                          ),
                        ],
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

class _AlertBanner extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const _AlertBanner({required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(147, 51, 234, 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Color borderColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.03),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}