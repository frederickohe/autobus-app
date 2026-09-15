import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/widgets/auth_screen_layout.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  final String phone;
  final String code;

  const ResetPassword({
    super.key,
    this.email = '',
    this.phone = '',
    required this.code,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submit() {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length != 4 || confirmPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter and confirm your 4-digit PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      ResetPasswordEvent(
        email: widget.email,
        phone: widget.phone,
        code: widget.code,
        newPassword: newPin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AuthScreenTokens.scaleOf(context);

    return AuthScreenScaffold(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Signin()),
              (route) => false,
            );
          } else if (state is AuthError && state.source == 'reset_password') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24 * scale,
                8 * scale,
                24 * scale,
                24 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthBackButton(),
                  SizedBox(height: 12 * scale),
                  AuthScreenHeader(
                    scale: scale,
                    title: 'New Pin',
                    subtitle: 'Enter your new pin',
                  ),
                  SizedBox(height: 32 * scale),
                  AuthFieldLabel(scale: scale, label: 'New Pin'),
                  SizedBox(height: 8 * scale),
                  AuthPinField(
                    scale: scale,
                    controller: _newPinController,
                    enabled: !isLoading,
                  ),
                  SizedBox(height: 16 * scale),
                  AuthFieldLabel(scale: scale, label: 'Confirm Pin'),
                  SizedBox(height: 8 * scale),
                  AuthPinField(
                    scale: scale,
                    controller: _confirmPinController,
                    enabled: !isLoading,
                  ),
                  SizedBox(height: 32 * scale),
                  AuthPrimaryButton(
                    scale: scale,
                    label: 'Confirm',
                    loading: isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
