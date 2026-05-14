import 'package:autobus/barrel.dart';
import 'package:flutter/services.dart';

// Ghana Card Formatter: User enters 467835625-4 → displays as GHA-467835625-4
class GhanaCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('-', '');
    
    // Only allow digits and max 10 characters (9 digits + 1 digit)
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limit to 10 digits total
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // Format: XXXXXXXXX-X (9 digits + dash + 1 digit)
    String formatted = '';
    
    if (text.length <= 9) {
      formatted = text;
    } else {
      formatted = text.substring(0, 9) + '-' + text.substring(9, 10);
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ghanaCardController = TextEditingController();

  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  String get _pin => _pinControllers.map((c) => c.text).join();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    companyController.dispose();
    ghanaCardController.dispose();
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final n in _pinFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  Widget _buildPinInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 52,
          child: TextField(
            controller: _pinControllers[index],
            focusNode: _pinFocusNodes[index],
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
              } else if (val.isEmpty && index > 0) {
                // Handle backspace: move focus to previous field and clear it
                _pinControllers[index - 1].clear();
                _pinFocusNodes[index - 1].requestFocus();
              }
            },
            onTap: () {
              _pinControllers[index].selection = TextSelection.collapsed(
                offset: _pinControllers[index].text.length,
              );
            },
            onSubmitted: (_) {
              if (index < 3) _pinFocusNodes[index + 1].requestFocus();
            },
            onEditingComplete: () {},
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<SuccessBloc, SuccessState>(
            listener: (context, state) {
              if (state is SuccessDisplaying) {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 1000),
                    reverseDuration: const Duration(milliseconds: 600),
                    child: const Success(),
                  ),
                );
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Registered) {
                Navigator.of(context).pushReplacement(
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 1000),
                    reverseDuration: const Duration(milliseconds: 600),
                    child: SignupOtp(phone: phoneController.text.trim()),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Centered text
                          Center(
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),

                          // Back button positioned on the left
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Center(
                        child: const AutobusBranding(
                          wordmarkFontSize: 26,
                          markCircleSize: 34,
                          spacing: 14,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox(
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: Text(
                                  'Username',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: usernameController,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: Text(
                                  'Phone',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: Text(
                                  'Company',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: companyController,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: Text(
                                  'Ghana Card',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: ghanaCardController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    GhanaCardFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    hintText: 'XXXXXXXXX-X',
                                    prefix: Text(
                                      'GHA-',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: Text(
                                  'Email',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
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
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: _buildPinInput(),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton(
                              onPressed: () async {
                                if (_pin.length != 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a 4-digit PIN'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                context.read<AuthBloc>().add(
                                  SignupEvent(
                                    username: usernameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: _pin,
                                    company: companyController.text.trim(),
                                    ghanaCard: ghanaCardController.text.trim(),
                                  ),
                                );
                              },
                              buttonText: 'Sign Up',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Have an Account ?',
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransition(
                                type: PageTransitionType.leftToRightWithFade,
                                childCurrent: widget,
                                duration: const Duration(milliseconds: 1000),
                                reverseDuration: const Duration(
                                  milliseconds: 1000,
                                ),
                                child: const Signin(),
                              ),
                            ); // Handle sign up navigation
                          },
                          child: Text(
                            'Log In',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
