import 'package:autobus/barrel.dart';

abstract class SuccessEvent extends Equatable {
  const SuccessEvent();

  @override
  List<Object?> get props => [];
}

class ShowSuccessEvent extends SuccessEvent {
  final String message;
  final String nextScreen;

  const ShowSuccessEvent({required this.message, required this.nextScreen});

  @override
  List<Object?> get props => [message, nextScreen];
}

class ClearSuccessEvent extends SuccessEvent {
  const ClearSuccessEvent();
}
