import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AutoChatRepository {
  final http.Client client;
  final Uri endpoint = Uri.parse(
    'http://173.212.253.3:8000/api/v1/webhooks/start-dialog',
  );

  AutoChatRepository({http.Client? client}) : client = client ?? http.Client();

  /// Sends a message to the webhook and returns the bot reply as a ChatMessage.
  ///
  /// [context] is the backend agent key (e.g. `order_agent`, `chatbot_agent`).
  Future<ChatMessage> sendMessage(
    String phone,
    String message, {
    required String context,
  }) async {
    final res = await client.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userid': phone,
        'message': message,
        'context': context,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('AutoChat API error: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final replyText =
        (data['message'] ??
                data['reply'] ??
                data['response'] ??
                data['text'] ??
                '')
            .toString();

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: phone,
      text: replyText,
      timestamp: DateTime.now(),
      sender: Sender.bot,
      status: MessageStatus.sent,
    );
  }
}
