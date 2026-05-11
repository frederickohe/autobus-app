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
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                if (index < 3) {
                  _pinFocusNodes[index + 1].requestFocus();
                } else {
                  _pinFocusNodes[index].unfocus();
                }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Ensure something happens even when `Signin` is opened directly
            // (not rendered inside `AuthWrapper`). `AuthWrapper` contains the
            // subscription gate.
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
          // Show loading indicator
          bool isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                // Your existing UI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: CustColors.mainCol,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CustColors.mainCol,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 50 * 0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: AutobusBranding(
                        wordmarkFontSize: 26,
                        markCircleSize: 34,
                        spacing: 14,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        'Email',
                        style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 12, 12, 12),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        controller: emailController,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          hintText: '',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        'PIN',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: _buildPinInput(enabled: !isLoading),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    childCurrent: const RecoverAccount(),
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    reverseDuration: const Duration(
                                      milliseconds: 600,
                                    ),
                                    child: const RecoverAccount(),
                                  ),
                                );
                              },
                        child: Text(
                          'Forgot PIN ?',
                          style: GoogleFonts.montserrat(
                            color: isLoading ? Colors.grey : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Center(
                      child: AppButton(
                        onPressed: isLoading
                            ? () {}
                            : () {
                                if (emailController.text.isEmpty ||
                                    _pin.length != 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter email and 4-digit PIN',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                context.read<AuthBloc>().add(
                                  LoginEvent(
                                    email: emailController.text,
                                    password: _pin,
                                  ),
                                );
                              },
                        buttonText: isLoading ? 'Signing in...' : 'Signin',
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: Text(
                        'Dont have an Account ?',
                        style: GoogleFonts.montserrat(
                          color: isLoading ? Colors.grey : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    childCurrent: const Signup(),
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    reverseDuration: const Duration(
                                      milliseconds: 600,
                                    ),
                                    child: const Signup(),
                                  ),
                                );
                              },
                        child: Text(
                          'Sign Up ',
                          style: GoogleFonts.montserrat(
                            color: isLoading ? Colors.grey : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading overlay
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}
