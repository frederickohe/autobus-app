import 'package:autobus/barrel.dart';
import 'package:flutter/services.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});
  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  String get _pin => _pinControllers.map((c) => c.text).join();

  @override
  void dispose() {
    emailController.dispose();
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final n in _pinFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  Widget _buildPinInput({required bool enabled}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 52,
          child: TextField(
            controller: _pinControllers[index],
            focusNode: _pinFocusNodes[index],
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              counterText: '',
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                if (index < 3) {
                  _pinFocusNodes[index + 1].requestFocus();
                } else {
                  _pinFocusNodes[index].unfocus();
                  // Auto-login when all 4 digits are entered and email is filled
                  if (emailController.text.isNotEmpty && _pin.length == 4) {
                    _submitLogin();
                  }
                }
              } else if (val.isEmpty && index > 0) {
                // Handle backspace: move focus to previous field and clear it
                _pinControllers[index - 1].clear();
                _pinFocusNodes[index - 1].requestFocus();
              }
            },
            onTap: () {
              // If user taps a later box, keep caret at end
              _pinControllers[index].selection = TextSelection.collapsed(
                offset: _pinControllers[index].text.length,
              );
            },
            onSubmitted: (_) {
              if (index < 3) _pinFocusNodes[index + 1].requestFocus();
            },
            onEditingComplete: () {
              // no-op; prevents default "done" behavior moving focus oddly
            },
          ),
        );
      }),
    );
  }

  void _submitLogin() {
    if (emailController.text.isEmpty || _pin.length != 4) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginEvent(
        email: emailController.text,
        password: _pin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== SIGNIN SCREEN BUILDING ===');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
            );
          } else if (state is AuthError && state.source == 'login') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CustColors.mainCol,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Login',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    Text(
                      'Email or Username',
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email or Username',
                        border: const UnderlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Password',
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 80.0),
                      child: _buildPinInput(enabled: !isLoading),
                    ),

                    const SizedBox(height: 12),
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
                          'Forgot Password ?',
                          style: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustColors.mainCol,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Dont have an Account ?",
                            style: GoogleFonts.montserrat(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransition(
                                  type: PageTransitionType.leftToRightWithFade,
                                  child: const Signup(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.montserrat(
                                color: CustColors.mainCol,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
