import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String _backendUrl;
  static late String paystackPublicKey;
  static late String paystackCallbackUrl;
  static late String privacyPolicyUrl;
  static late String termsOfServiceUrl;

  static Future<void> init() async {
    await dotenv.load();
    _backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';
    paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    paystackCallbackUrl = dotenv.env['PAYSTACK_CALLBACK_URL'] ?? '';
    privacyPolicyUrl =
        dotenv.env['PRIVACY_POLICY_URL'] ?? 'https://useautobus.com/privacy';
    termsOfServiceUrl =
        dotenv.env['TERMS_OF_SERVICE_URL'] ?? 'https://useautobus.com/terms';
  }

  static String get backendUrl => _backendUrl;
}
