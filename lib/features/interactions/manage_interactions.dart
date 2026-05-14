import 'package:autobus/barrel.dart';

class ManageInteractions extends StatelessWidget {
  const ManageInteractions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0814),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1333),
                  Color(0xFF120D26),
                  Color(0xFF0A0814),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with Back Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            color: Colors.white.withValues(alpha: 0.03),
                            backgroundBlendMode: BlendMode.overlay,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Manage Interactions',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Welcome Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Chats',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Interact with AI-driven analytics to gain insights, monitor performance, and support decision-making.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Action Cards Grid
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.0,
                            children: [
                              _InteractionCard(
                                title: 'Start Interaction',
                                icon: Icons.search,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AutoBus(
                                        title: 'Interactions',
                                        webhookContext: 'interactions_agent',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _InteractionCard(
                                title: 'View Interactions',
                                icon: Icons.history,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const InteractionHistoryPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _InteractionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.9),
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractionHistoryPage extends StatelessWidget {
  const InteractionHistoryPage({super.key});

  static const _backgroundStart = Color(0xFF180B2A);
  static const _backgroundEnd = Color(0xFF0D0617);
  static const _cardBorder = Color.fromRGBO(255, 255, 255, 0.4);

  Widget _interactionCard({
    required String title,
    required String id,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'Manage Interactions',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _interactionCard(
                      title: 'Bag of rice ..',
                      id: 'ID TRF 26342348264',
                      date: '08 / 01 /2026',
                    ),
                    const SizedBox(height: 20),
                    _interactionCard(
                      title: 'Fruit Jar',
                      id: 'ID TRF 26342348264',
                      date: '08 / 01 /2026',
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
