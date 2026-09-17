import 'dart:convert';

import 'package:autobus/common_design/user_facing_error.dart';
import 'package:autobus/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AutoChatRepository {
  final http.Client client;

  AutoChatRepository({http.Client? client}) : client = client ?? http.Client();

  Uri get _endpoint => Uri.parse(
        '${AppConfig.backendUrl}/api/v1/webhooks/start-dialog',
      );

  /// Sends a message to the webhook and returns the bot reply as a ChatMessage.
  ///
  /// [companyNumber] is the merchant ``users.id`` (`company_number` on the API).
  /// When empty, the server uses legacy ``userid``-only routing.
  Future<ChatMessage> sendMessage(
    String phone,
    String message, {
    required String companyNumber,
    required String context,
  }) async {
    final trimmedCompany = companyNumber.trim();
    final body = <String, dynamic>{
      'userid': phone,
      'customer_number': phone,
      'message': message,
      'context': context,
      if (trimmedCompany.isNotEmpty) 'company_number': trimmedCompany,
    };

    final res = await client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConfig.agentTimeout);

    if (res.statusCode == 401) {
      throw Exception(AppUserMessages.session);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(AppUserMessages.load);
    }

    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      throw Exception(AppUserMessages.load);
    }

    final replyText = _extractReply(data);
    if (replyText.isEmpty) {
      throw Exception("I couldn't get a reply. Please try again.");
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: phone,
      text: replyText,
      timestamp: DateTime.now(),
      sender: Sender.bot,
      status: MessageStatus.sent,
    );
  }

  String _extractReply(dynamic data) {
    if (data == null) return '';
    if (data is String) return data.trim();
    if (data is List && data.isNotEmpty) return _extractReply(data.first);
    if (data is! Map) return '';

    const keys = [
      'message',
      'reply',
      'response',
      'text',
      'output',
      'content',
      'answer',
      'assistant',
    ];
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    for (final key in ['data', 'result', 'payload', 'body']) {
      final nested = _extractReply(data[key]);
      if (nested.isNotEmpty) return nested;
    }
    return '';
  }
}
