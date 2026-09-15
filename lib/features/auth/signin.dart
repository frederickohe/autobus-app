import 'package:autobus/barrel.dart';
import 'package:autobus/common_design/widgets/auth_field.dart';
import 'package:autobus/common_design/widgets/auth_screen_layout.dart';
import 'package:flutter/services.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final email = _emailController.text.trim();
    final pin = _pinController.text.trim();
    if (email.isEmpty || pin.length != 4) return;

    context.read<AuthBloc>().add(
      LoginEvent(identifier: email, password: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AuthScreenTokens.scaleOf(context);
    final fieldWidth = AuthScreenTokens.fieldWidth(scale);
    final fieldHeight = AuthScreenTokens.fieldHeight(scale);

    return AuthScreenScaffold(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
            );
          } else if (state is AuthError && state.source == 'login') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.montserrat()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24 * scale, 8 * scale, 24 * scale, 24 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthBackButton(),
                SizedBox(height: 12 * scale),
                AuthScreenHeader(
                  scale: scale,
                  title: 'Sign In',
                  subtitle: 'Agentic business management',
                ),
                SizedBox(height: 32 * scale),
                AuthField(
                  width: fieldWidth,
                  height: fieldHeight,
                  scale: scale,
                  icon: Icons.person_outline,
                  controller: _emailController,
                  enabled: !isLoading,
                  hintText: 'Email or username',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
                AuthField(
                  width: fieldWidth,
                  height: fieldHeight,
                  scale: scale,
                  icon: Icons.lock_outline,
                  controller: _pinController,
                  enabled: !isLoading,
                  obscureText: true,
                  hintText: '4-digit PIN',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _submitLogin(),
                ),
                SizedBox(height: 16 * scale),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const RecoverAccount(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.montserrat(
                        color: AuthScreenTokens.labelColor,
                        fontSize: 13 * scale.clamp(0.9, 1.05),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28 * scale),
                AuthPrimaryButton(
                  scale: scale,
                  label: 'Sign in',
                  loading: isLoading,
                  onPressed: _submitLogin,
                ),
                SizedBox(height: 32 * scale),
                AuthLinkText(
                  scale: scale,
                  prompt: "Don't have an account?",
                  action: 'Sign Up',
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransition(
                        type: PageTransitionType.leftToRightWithFade,
                        child: const Signup(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
