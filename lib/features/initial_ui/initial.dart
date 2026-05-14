import 'package:autobus/barrel.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    print('=== SPLASH SCREEN SHOWING ===');
    
    Future.delayed(const Duration(seconds: 3), () {
      print('=== SPLASH TIMEOUT - NAVIGATING TO AUTH ===');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashPge();
  }
}
