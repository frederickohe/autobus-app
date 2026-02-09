part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final dynamic user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class Registered extends AuthState {
  final String message;  
  const Registered({ required this.message});
  @override
  List<Object> get props => [message];
}

class Unauthenticated extends AuthState {
  final String? message;
  final String? source;

  const Unauthenticated({this.message, this.source});

  @override
  List<Object> get props => [message ?? ''];
}

class AuthError extends AuthState {
  final String message;
  final String source; // 'login' or 'signup'

  const AuthError({required this.message, required this.source});

  @override
  List<Object> get props => [message, source];
}

// Add these alongside your existing states
class EmailExists extends AuthState {
  final String email;

  const EmailExists({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetCodeSent extends AuthState {
  final String email;
  final String message;

  const ResetCodeSent({required this.email, required this.message});

  @override
  List<Object> get props => [email, message];
}

class ResetCodeVerified extends AuthState {
  final String email;
  final String code;

  const ResetCodeVerified({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object> get props => [message];
}