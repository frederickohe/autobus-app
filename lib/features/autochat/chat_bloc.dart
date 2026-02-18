import 'package:bloc/bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'services/autochat_repository.dart';
import 'models/chat_message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AutoChatRepository repository;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    List<ChatMessage> current = [];
    if (state is ChatLoadSuccess) {
      current = List.from((state as ChatLoadSuccess).messages);
    }

    // Optimistic user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: event.phone,
      text: event.message,
      timestamp: DateTime.now(),
      sender: Sender.user,
      status: MessageStatus.pending,
    );

    current.add(userMsg);
    emit(ChatLoadSuccess(List.from(current)));

    try {
      final botReply = await repository.sendMessage(event.phone, event.message);

      // mark user message as sent
      final updated = current.map((m) {
        if (m.id == userMsg.id) return m.copyWith(status: MessageStatus.sent);
        return m;
      }).toList();

      updated.add(botReply);
      emit(ChatLoadSuccess(updated));
    } catch (e) {
      // mark user message as failed
      final failed = current.map((m) {
        if (m.id == userMsg.id) return m.copyWith(status: MessageStatus.failed);
        return m;
      }).toList();
      emit(ChatLoadSuccess(failed));
    }
  }
}
