import 'package:autobus/barrel.dart';

/// First-run onboarding — Figma ONBOARDING 402×874.
class OnboardingPage extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  static const _designWidth = 402.0;
  static const _designHeight = 874.0;
  static const _backgroundColor = Color(0xFFF3F3F7);
  static const _buttonColor = Color(0xFF2D0C51);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / _designWidth;

    final imageWidth = 268.18 * scale;
    final imageHeight = 226 * scale;
    final buttonWidth = 333 * scale;
    final buttonHeight = 64 * scale;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Column(
                children: [
                  SizedBox(height: 264 * scale),
                  Center(
                    child: Image.asset(
                      'assets/img/welcomeai.png',
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 35 * scale),
                  Text(
                    'Run your whole business from one app',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20 * scale.clamp(0.85, 1.15),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    'Chats, orders, marketing, and an AI that knows your '
                    'business — all in one place.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14 * scale.clamp(0.9, 1.1),
                      fontWeight: FontWeight.w400,
                      height: 1.55,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Material(
                      color: _buttonColor,
                      borderRadius: BorderRadius.circular(30 * scale),
                      child: InkWell(
                        onTap: onFinished,
                        borderRadius: BorderRadius.circular(30 * scale),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get started',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16 * scale.clamp(0.9, 1.1),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10 * scale),
                              Transform.rotate(
                                angle: -1.5708,
                                child: const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 64 * (size.height / _designHeight)),
                ],
              ),
        ),
      ),
    );
  }
}
