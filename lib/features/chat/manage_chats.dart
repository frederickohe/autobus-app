import 'package:autobus/barrel.dart';

class ManageChats extends StatelessWidget {
  const ManageChats({super.key});

  static const Color _backgroundStart = Color(0xFF160A2C);
  static const Color _backgroundEnd = Color(0xFF0C0418);
  static const Color _cardBorder = Color.fromRGBO(255, 255, 255, 0.15);
  static const Color _alertBorder = Color.fromRGBO(168, 85, 247, 0.5);

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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _cardBorder),
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
                          'Manage Chats',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
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
                            'Welcome to Chats',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              'Deliver instant, intelligent customer support with AI trained on your business data through linked social messaging channels',
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'You not linked any chat platform',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        children: [
                          _ActionCard(
                            borderColor: _cardBorder,
                            icon: Icons.link,
                            label: 'Link Channel',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageChannels(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            borderColor: _cardBorder,
                            icon: Icons.mark_chat_unread_outlined,
                            label: 'Live Chats',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LiveChatsPage(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            borderColor: _cardBorder,
                            icon: Icons.chat_bubble_outline,
                            label: 'All Chats',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllChatsPage(),
                                ),
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
        color: const Color.fromRGBO(88, 28, 135, 0.18),
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.03),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 16),
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