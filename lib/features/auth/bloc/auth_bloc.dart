import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<CheckAuthEvent>(_onCheckAuth);
    on<LogoutEvent>(_onLogout);
    on<VerifyResetCodeEvent>(_onVerifyResetCode);
    on<ResetPasswordEvent>(_onResetPassword);
    on<CheckEmailExistsEvent>(_onCheckEmailExists);
    on<SendResetCodeEvent>(_onSendResetCode);
  }

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': event.email, 'password': event.password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        // Fetch user data using access token
        final userResponse = await http.get(
          Uri.parse('http://35.208.64.180:8000/api/v1/user/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          await prefs.setString('user', json.encode(userData));
          emit(Authenticated(user: userData));
        } else {
          String errorMsg = 'Failed to fetch user data';
          try {
            final errorData = json.decode(userResponse.body);
            if (errorData is Map && errorData['detail'] != null) {
              errorMsg = errorData['detail'];
            }
          } catch (_) {}
          print('User fetch error: ' + userResponse.body);
          emit(AuthError(message: errorMsg, source: 'login'));
        }
      } else {
        String errorMsg = 'Login failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'login'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'login'));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': event.firstname,
          'last_name': event.lastname,
          'username': event.username,
          'phone': event.phone,
          'email': event.email,
          'password': event.password,
        }),
      );

      if (response.statusCode == 200) {
        // The endpoint does not return user data or token
        String msg = 'Signup successful';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            msg = data['detail'];
          }
        } catch (_) {
          msg = response.body;
        }
        emit(Registered(message: "Signup successful"));
      } else {
        String errorMsg = 'Signup failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'signup'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'signup'));
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userString = prefs.getString('user');

      if (token != null && userString != null) {
        final user = json.decode(userString);
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'check_auth'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    emit(Unauthenticated());
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': event.email,
          'new_password': event.newPassword,
        }),
      );

      if (response.statusCode == 200) {
        emit(PasswordResetSuccess(message: 'Password reset successfully'));
      } else {
        String errorMsg = 'Password reset failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'reset_password'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'reset_password'));
    }
  }

  Future<void> _onCheckEmailExists(
    CheckEmailExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/verify-account'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': event.email}),
      );

      if (response.statusCode == 200) {
          emit(EmailExists(email: event.email));
      } else {
        String errorMsg = 'Email check failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'check_email'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'check_email'));
    }
  }

  //////////////   OTP Code Handers //////////////////////

  Future<void> _onSendResetCode(
    SendResetCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/send-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': event.email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(ResetCodeSent(
          email: event.email,
          message: data['message'] ?? 'Reset code sent successfully',
        ));
      } else {
        String errorMsg = 'Failed to send reset code';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'send_reset_code'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'send_reset_code'));
    }
  }

  Future<void> _onVerifyResetCode(
    VerifyResetCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('http://35.208.64.180:8000/api/v1/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': event.email, 'code': event.code}),
      );

      if (response.statusCode == 200) {
        emit(ResetCodeVerified(email: event.email, code: event.code));
      } else {
        String errorMsg = 'Invalid verification code';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}
        emit(AuthError(message: errorMsg, source: 'verify_code'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString(), source: 'verify_code'));
    }
  }
}
