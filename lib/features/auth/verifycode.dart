import 'package:autobus/barrel.dart';

class VerifyCode extends StatefulWidget {
  final String email;

  const VerifyCode({super.key, required this.email});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetCodeVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPassword(email: state.email, code: codeController.text),
            ),
          );
        }
      },
      child: Scaffold(
        // ... your existing scaffold code
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.32,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Back',
                          style: GoogleFonts.imprima(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'VerifyCode',
                        style: GoogleFonts.imprima(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/img/bot.png'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  'Enter Code',
                  style: GoogleFonts.imprima(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: UnderlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Did Not Receeve Code? Resend Code',
                    style: GoogleFonts.imprima(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: AppButton(
                  onPressed: () {
                    if (codeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter the verification code'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    context.read<AuthBloc>().add(
                      VerifyResetCodeEvent(
                        email: widget.email,
                        code: codeController.text,
                      ),
                    );
                  },
                  buttonText: 'VerifyCode',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Center(
                child: Text(
                  'Dont have an Account ?',
                  style: GoogleFonts.imprima(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        childCurrent: const Signup(),
                        duration: const Duration(milliseconds: 1000),
                        reverseDuration: const Duration(milliseconds: 600),
                        child: const Signup(),
                      ),
                    );
                  },
                  child: Text(
                    'Verify',
                    style: GoogleFonts.imprima(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
