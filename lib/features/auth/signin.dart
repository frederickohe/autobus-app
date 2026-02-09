import 'package:autobus/barrel.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});
  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                          'Signin',
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
                  child: Text('Email', style: GoogleFonts.imprima(
                                  color: const Color.fromARGB(255, 12, 12, 12),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text('Password', style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: passwordController,
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
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          childCurrent: const RecoverAccount(),
                          duration: const Duration(milliseconds: 1000),
                          reverseDuration: const Duration(milliseconds: 600),
                          child: const RecoverAccount(),
                        ),
                      );
                    },
                    child:  Text(
                      'Forgot Password ?',
                      style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Center(
                  child: AppButton(
                    onPressed: () {
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text('Please fill all fields', style: GoogleFonts.imprima(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100,
                                ),),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<AuthBloc>().add(
                        LoginEvent(
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                      );
                    },
                    buttonText: 'Signin',
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
