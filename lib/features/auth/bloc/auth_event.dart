part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupEvent extends AuthEvent {
  final String firstname;
  final String lastname;
  final String username;
  final String phone;
  final String email;
  final String password;

  const SignupEvent({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [firstname, lastname, username, phone, email, password];
}

class CheckAuthEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent({required this.email});

  @override
  List<Object> get props => [email];
}

// Add these alongside your existing events
class CheckEmailExistsEvent extends AuthEvent {
  final String email;

  const CheckEmailExistsEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class SendResetCodeEvent extends AuthEvent {
  final String email;

  const SendResetCodeEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyResetCodeEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyResetCodeEvent({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String code; // Optional, if you need to pass the code
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, code, newPassword];
}