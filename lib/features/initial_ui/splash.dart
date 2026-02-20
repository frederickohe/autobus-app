import 'package:autobus/barrel.dart';

class SplashPge extends StatefulWidget {
  const SplashPge({super.key});

  @override
  State<SplashPge> createState() => _SplashPgeState();
}

class _SplashPgeState extends State<SplashPge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
          ),
        );

    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
          ),
        );

    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Image.asset(
                    "assets/img/splashback.png",
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.28),

                      SlideTransition(
                        position: _logoSlide,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Center(
                              child: Image.asset(
                                "assets/icons/autologo.png",
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SlideTransition(
                        position: _taglineSlide,
                        child: FadeTransition(
                          opacity: _taglineFade,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Your ride, your way.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.imprima(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 13,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      FadeTransition(
                        opacity: _loaderFade,
                        child: const _PulsingDots(),
                      ),

                      SizedBox(height: size.height * 0.07),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Three pulsing dots that animate sequentially to indicate loading.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _dotAnimation(double offset) {
    return Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          offset,
          (offset + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(animation: _dotAnimation(0.0)),
        const SizedBox(width: 8),
        _Dot(animation: _dotAnimation(0.2)),
        const SizedBox(width: 8),
        _Dot(animation: _dotAnimation(0.4)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Animation<double> animation;
  const _Dot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
