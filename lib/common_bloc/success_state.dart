import 'package:autobus/barrel.dart';

abstract class SuccessState extends Equatable {
  const SuccessState();

  @override
  List<Object?> get props => [];
}

class SuccessInitial extends SuccessState {
  const SuccessInitial();
}

class SuccessDisplaying extends SuccessState {
  final String message;
  final String nextScreen;

  const SuccessDisplaying({required this.message, required this.nextScreen});

  @override
  List<Object?> get props => [message, nextScreen];
}

class SuccessCleared extends SuccessState {
  const SuccessCleared();
}
