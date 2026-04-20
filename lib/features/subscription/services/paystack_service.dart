import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:autobus/config/app_config.dart';

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  /// For subscriptions, pass a [planCode] (e.g. PLN_xxxx from dashboard).
  /// For one-time payments, leave [planCode] null and pass [amount] in pesewas.
  Future<String?> launch({
    required BuildContext context,
    required String email,
    required String reference,
    String? planCode, // pass this for subscriptions
    int? amount, // pass this for one-time payments
    String currency = 'GHS', // change to NGN, USD etc as needed
    required String callbackUrl,
    required VoidCallback onSuccess,
    required VoidCallback onCancelled,
  }) async {

    try {
      await FlutterPaystackPlus.openPaystackPopup(
        context: context,
        publicKey: AppConfig.paystackPublicKey,
        customerEmail: email,
        reference: reference,
        plan: planCode,
        amount: amount != null ? (amount * 100).toString() : '0',
        currency: currency,
        callBackUrl: callbackUrl,
        onSuccess: onSuccess,
        onClosed: onCancelled,
      );
      return reference;
    } catch (e) {
      log('Paystack error: $e');
      return null;
    }
  }
}
