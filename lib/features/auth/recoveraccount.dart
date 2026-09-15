import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/widgets/auth_field.dart';
import 'package:autobus/common_design/widgets/auth_screen_layout.dart';

class RecoverAccount extends StatefulWidget {
  const RecoverAccount({super.key});

  @override
  State<RecoverAccount> createState() => _RecoverAccountState();
}

class _RecoverAccountState extends State<RecoverAccount> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    context.read<AuthBloc>().add(CheckEmailExistsEvent(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    final scale = AuthScreenTokens.scaleOf(context);
    final fieldWidth = AuthScreenTokens.fieldWidth(scale);
    final fieldHeight = AuthScreenTokens.fieldHeight(scale);

    return AuthScreenScaffold(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is EmailExists) {
            context.read<AuthBloc>().add(
              SendResetCodeEvent(email: state.email, phone: state.phone),
            );
          } else if (state is ResetCodeSent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifyCode(
                  email: state.email,
                  phone: state.phone,
                ),
              ),
            );
          } else if (state is AuthError &&
              (state.source == 'check_email' ||
                  state.source == 'send_reset_code')) {
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
                    title: 'Reset Pin',
                    subtitle: 'Enter your phone number',
                  ),
                  SizedBox(height: 32 * scale),
                  AuthFieldLabel(scale: scale, label: 'Phone'),
                  SizedBox(height: 8 * scale),
                  AuthField(
                    width: fieldWidth,
                    height: fieldHeight,
                    scale: scale,
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    enabled: !isLoading,
                    hintText: '0244123456',
                    keyboardType: TextInputType.phone,
                    onSubmitted: (_) => _continue(),
                  ),
                  SizedBox(height: 32 * scale),
                  AuthPrimaryButton(
                    scale: scale,
                    label: 'Continue',
                    loading: isLoading,
                    onPressed: _continue,
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
