import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String userId;
  final String message;

  const SendMessage({required this.userId, required this.message});

  @override
  List<Object?> get props => [userId, message];
}

class LoadHistory extends ChatEvent {
  const LoadHistory();
}
