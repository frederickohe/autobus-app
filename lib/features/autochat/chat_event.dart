import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String phone;
  final String message;

  /// Backend webhook `context` (e.g. `order_agent`, `products_agent`).
  final String context;

  /// When true, the message is sent to the webhook but not shown in the UI.
  final bool hidden;

  const SendMessage({
    required this.phone,
    required this.message,
    required this.context,
    this.hidden = false,
  });

  @override
  List<Object?> get props => [phone, message, context, hidden];
}

class LoadHistory extends ChatEvent {
  const LoadHistory();
}
