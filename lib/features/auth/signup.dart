import 'package:autobus/barrel.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ghanaCardController = TextEditingController();

  // Add this variable to track password visibility
  bool _isPasswordVisible = false;

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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
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
                                  'Email',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
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
                                  'Password',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                context.read<AuthBloc>().add(
                                  SignupEvent(
                                    username: usernameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
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
                            fontSize: 12,
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
                              fontSize: 14,
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
