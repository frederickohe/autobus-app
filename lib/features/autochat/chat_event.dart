import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String phone;
  final String message;

  const SendMessage({required this.phone, required this.message});

  @override
  List<Object?> get props => [phone, message];
}

class LoadHistory extends ChatEvent {
  const LoadHistory();
}
