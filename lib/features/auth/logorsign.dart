import 'dart:ui';
import 'package:autobus/barrel.dart';

class LogorSign extends StatelessWidget {
  const LogorSign({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/splash.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),
                  Image.asset(
                    "assets/icons/autologo.png",
                    height: 52,
                    fit: BoxFit.contain,
                  ),

                  const Spacer(),

                  _BottomCard(),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: CustColors.mainCol.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Welcome aboard',
                  style: GoogleFonts.imprima(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _AuthButton(
                      label: 'Log In',
                      onPressed: () {
                        Navigator.of(context).push(
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            childCurrent: const Signin(),
                            duration: const Duration(milliseconds: 900),
                            reverseDuration: const Duration(milliseconds: 700),
                            child: const Signin(),
                          ),
                        );
                      },
                    ),

                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),

                    _AuthButton(
                      label: 'Sign Up',
                      onPressed: () {
                        Navigator.of(context).push(
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            childCurrent: const Signup(),
                            duration: const Duration(milliseconds: 900),
                            reverseDuration: const Duration(milliseconds: 600),
                            child: const Signup(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegalLink(label: 'Terms'),
                  _LegalDot(),
                  _LegalLink(label: 'Privacy'),
                  _LegalDot(),
                  _LegalLink(label: 'Help'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AuthButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 52),
        ),
        child: Text(
          label,
          style: GoogleFonts.imprima(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  const _LegalLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: navigate to the respective pages....
      },
      child: Text(
        label,
        style: GoogleFonts.imprima(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _LegalDot extends StatelessWidget {
  const _LegalDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '·',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 14,
        ),
      ),
    );
  }
}
