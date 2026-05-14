import 'package:autobus/barrel.dart';

class AllOrdersHistory extends StatelessWidget {
  const AllOrdersHistory({super.key});

  static const _backgroundStart = Color(0xFF1D1033);
  static const _backgroundEnd = Color(0xFF0B061D);
  static const _cardBorder = Color.fromRGBO(255, 255, 255, 0.4);

  Widget _orderCard({
    required String title,
    required String id,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(40),
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
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        'All Orders',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 64),
                  ],
                ),
                const SizedBox(height: 48),
                _orderCard(
                  title: 'Bag of rice ..',
                  id: 'ID TRF 26342348264',
                  date: '08 / 01 / 2026',
                ),
                const SizedBox(height: 24),
                _orderCard(
                  title: 'Fruit Jar',
                  id: 'ID TRF 26342348264',
                  date: '08 / 01 / 2026',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
