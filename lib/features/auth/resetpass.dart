import 'package:autobus/barrel.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  final String code;

  const ResetPassword({super.key , required this.email, required this.code});
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Padding(
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
                        width: MediaQuery.of(context).size.width * 0.2,
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
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          'Reset Password',
                          style: GoogleFonts.imprima(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
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
                    'New Password',
                    style: GoogleFonts.imprima(
                      color: const Color.fromARGB(255, 12, 12, 12),
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: newPasswordController,
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
                    'Confirm Password',
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
                    controller: confirmPasswordController,
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
                      'At least 8 characters, 1 uppercase, 1 lowercase, 1 number',
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
                      if (newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(
                        ResetPasswordEvent(
                          email: widget.email,
                          code: widget.code,
                          newPassword: newPasswordController.text,
                        ),
                      );
                    },
                    buttonText: 'ResetPassword',
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
                      'Sign Up ',
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
          );
        },
      ),
    );
  }
}
