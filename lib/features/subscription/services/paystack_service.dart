import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';
import 'package:autobus/barrel.dart';

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  final _paystack = Paystack();
  bool _initialized = false;

  Future<bool> initialize() async {
    try {
      final response = await _paystack.initialize(
        publicKey: AppConfig.paystackPublicKey, // pull from your AppConfig
      );
      _initialized = response;
      log('Paystack: ${response ? 'Initialized' : 'Failed to initialize'}');
      return response;
    } on PlatformException catch (e) {
      log('Paystack init error: ${e.message}');
      return false;
    }
  }

  Future<TransactionResponse?> launch(String accessCode) async {
    if (!_initialized) {
      log('Paystack: SDK not initialized. Call initialize() first.');
      return null;
    }

    try {
      final response = await _paystack.launch(accessCode);

      switch (response.status) {
        case 'success':
          log('Paystack: Transaction successful. Ref: ${response.reference}');
          return response;
        case 'cancelled':
          log('Paystack: Transaction cancelled — ${response.message}');
          return null;
        default:
          log('Paystack: Transaction failed — ${response.message}');
          return null;
      }
    } on PlatformException catch (e) {
      log('Paystack launch error: ${e.message}');
      return null;
    }
  }
}
