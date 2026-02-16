import 'package:flutter_bloc/flutter_bloc.dart';
import 'assistant_event.dart';
import 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  AssistantBloc() : super(AssistantInitial()) {
    on<SendCommandEvent>(_onSendCommand);
  }

  Future<void> _onSendCommand(
    SendCommandEvent event,
    Emitter<AssistantState> emit,
  ) async {
    emit(AssistantLoading());
    try {
      // TODO: Replace with actual API call to ChatGPT
      await Future.delayed(const Duration(seconds: 2));
      final response = "AI Response to: ${event.command}";
      emit(AssistantSuccess(response: response));
    } catch (e) {
      emit(AssistantError(message: e.toString()));
    }
  }
}
