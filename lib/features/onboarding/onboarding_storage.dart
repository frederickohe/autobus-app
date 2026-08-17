import 'package:autobus/barrel.dart';

/// Persists first-run splash and per-user welcome completion.
class OnboardingStorage {
  static const _kSplashSeen = 'onboarding.splashSeen';
  static const _kWelcomeCompletedPrefix = 'onboarding.welcomeCompleted.';

  Future<bool> hasSeenSplash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSplashSeen) ?? false;
  }

  Future<void> markSplashSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSplashSeen, true);
  }

  Future<bool> hasCompletedWelcome(String userKey) async {
    final key = userKey.trim();
    if (key.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_kWelcomeCompletedPrefix$key') ?? false;
  }

  Future<void> markWelcomeCompleted(String userKey) async {
    final key = userKey.trim();
    if (key.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kWelcomeCompletedPrefix$key', true);
  }

  /// Best-effort stable id for welcome completion (email or phone).
  static String userKeyFromMap(Map<String, dynamic> user) {
    final email = (user['email'] ?? user['user_email'] ?? user['userEmail'] ?? '')
        .toString()
        .trim();
    if (email.isNotEmpty) return email.toLowerCase();

    final phone =
        (user['phone'] ??
                user['phone_number'] ??
                user['user_phone'] ??
                user['userPhone'] ??
                '')
            .toString()
            .trim();
    if (phone.isNotEmpty) return phone;

    final id = (user['id'] ?? user['user_id'] ?? user['userId'] ?? '').toString();
    return id.trim();
  }
}
