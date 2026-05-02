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

  const SendMessage({
    required this.phone,
    required this.message,
    required this.context,
  });

  @override
  List<Object?> get props => [phone, message, context];
}

class LoadHistory extends ChatEvent {
  const LoadHistory();
}
