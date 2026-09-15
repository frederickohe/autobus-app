import 'package:autobus/barrel.dart';
import 'package:autobus/features/onboarding/onboarding_page.dart';
import 'package:autobus/features/onboarding/onboarding_storage.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _navigated = false;
  bool? _hasSeenSplash;
  Timer? _splashTimer;
  Timer? _authStallTimer;

  @override
  void initState() {
    super.initState();
    print('=== SPLASH WRAPPER INIT ===');
    _startAuthStallTimer();
    _loadSplashPref();
  }

  void _startAuthStallTimer() {
    _authStallTimer?.cancel();
    _authStallTimer = Timer(const Duration(seconds: 12), () {
      if (_navigated || !mounted) return;
      print('=== AUTH STALL TIMEOUT - PROCEEDING ===');
      _goToAuth();
    });
  }

  Future<void> _loadSplashPref() async {
    final seen = await OnboardingStorage().hasSeenSplash();
    if (!mounted) return;
    setState(() => _hasSeenSplash = seen);
    _handleAuthResolved(context.read<AuthBloc>().state);
  }

  void _goToAuth() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _splashTimer?.cancel();
    _authStallTimer?.cancel();
    print('=== NAVIGATING TO AUTH WRAPPER ===');
    if (_hasSeenSplash == false) {
      unawaited(OnboardingStorage().markSplashSeen());
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  void _scheduleSplashTimeout() {
    _splashTimer?.cancel();
    _splashTimer = Timer(const Duration(seconds: 3), _goToAuth);
  }

  void _handleAuthResolved(AuthState state) {
    if (state is Authenticated || state is TokenRefreshed) {
      // Logged-in users skip the marketing splash and go straight to the app.
      _goToAuth();
      return;
    }

    if (state is Unauthenticated ||
        state is SessionExpired ||
        state is TokenRefreshFailed ||
        state is AuthError) {
      if (_hasSeenSplash == true) {
        _goToAuth();
      } else {
        _scheduleSplashTimeout();
      }
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _authStallTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_hasSeenSplash == null) return;
        _handleAuthResolved(state);
      },
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          _hasSeenSplash != null,
      builder: (context, state) {
        if (_hasSeenSplash == null) {
          return const Scaffold(
            body: Center(child: AutobusLoadingIndicator()),
          );
        }

        if (state is Authenticated || state is TokenRefreshed) {
          return const Scaffold(
            body: Center(child: AutobusLoadingIndicator()),
          );
        }

        if (state is AuthInitial ||
            state is AuthLoading ||
            state is TokenRefreshing) {
          return const Scaffold(
            body: Center(child: AutobusLoadingIndicator()),
          );
        }

        if ((state is Unauthenticated || state is SessionExpired) &&
            _hasSeenSplash == false) {
          return OnboardingPage(onFinished: _goToAuth);
        }

        return const Scaffold(
          body: Center(child: AutobusLoadingIndicator()),
        );
      },
    );
  }
}
