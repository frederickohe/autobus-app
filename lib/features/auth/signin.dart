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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle successful login
          if (state is Authenticated) {
            // Navigate to welcome page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Welcome()),
              (route) => false,
            );
          }
          // Handle errors
          else if (state is AuthError && state.source == 'login') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.imprima(color: Colors.white),
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
                            style: GoogleFonts.imprima(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w100,
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
                        'Email',
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
                        'Password',
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
                        controller: passwordController,
                        enabled: !isLoading,
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
                          'Forgot Password ?',
                          style: GoogleFonts.imprima(
                            color: isLoading ? Colors.grey : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: AppButton(
                        onPressed: isLoading
                            ? () {}
                            : () {
                                if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please fill all fields',
                                        style: GoogleFonts.imprima(
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
                                    password: passwordController.text,
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
                        style: GoogleFonts.imprima(
                          color: isLoading ? Colors.grey : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w100,
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
                          style: GoogleFonts.imprima(
                            color: isLoading ? Colors.grey : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading overlay
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}
